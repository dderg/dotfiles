"""Multi-LLM routing: failover and (weighted) round-robin across N providers.

``MultiLLMProvider`` wraps an ordered list of :class:`LLMProvider` members and a
:class:`~hindsight_api.config.LLMStrategyConfig`, exposing the same public surface
as a single ``LLMProvider`` so it drops into every existing call path (including
``with_config()`` / ``ConfiguredLLMProvider``).

Member 0 is the **primary** (the operation's unindexed/base LLM); members 1..N are
the indexed extras (``HINDSIGHT_API_<OP>LLM_<n>_*``). Each member keeps its own
internal retry budget, so we only advance to the next member after a member has
exhausted its retries and raised.

Strategies:
- ``failover``: try members in declared order ``[0..N]``.
- ``round-robin``: rotate the starting member per request (optionally weighted),
  then fall through the remaining members on error.

Batch retain and any direct ``_provider_impl`` access operate on the **primary
member only** (via attribute passthrough) — failover/round-robin apply to the
interactive ``call`` / ``call_with_tools`` paths.
"""

import asyncio
import logging
import os
import socket
import threading
import time
import uuid
from typing import TYPE_CHECKING, Any
from urllib.parse import urlparse

from ..config import LLM_STRATEGY_FAILOVER, LLMStrategyConfig
from .llm_wrapper import LLMProvider, OutputTooLongError

if TYPE_CHECKING:
    from .llm_wrapper import ConfiguredLLMProvider, LLMToolCallResult

logger = logging.getLogger(__name__)


def _should_failover(exc: BaseException) -> bool:
    """Whether ``exc`` from one member should trigger a try on the next member.

    Generic ``Exception`` instances (network errors, provider 5xx, timeouts after
    a member's own retries) fail over. ``OutputTooLongError`` is propagated — a
    different provider won't fit an over-length output either. ``CancelledError``,
    ``KeyboardInterrupt`` and ``SystemExit`` are ``BaseException`` (not
    ``Exception``) and therefore propagate unchanged.
    """
    if isinstance(exc, OutputTooLongError):
        return False
    return isinstance(exc, Exception)


class _MemberBreaker:
    """Per-member availability state (local overlay patch, not upstream).

    Two independent signals mark a member unavailable; ``filter_order`` moves
    unavailable members to the back of the try-order (never removes them):
    1. Passive cooldown: a request failure starts a cooldown that doubles on
       consecutive failures up to a cap; any success resets it.
    2. Active health: ``_HealthProber`` TCP-probes each member's endpoint on an
       interval and flips a boolean, so requests never wait on a dead endpoint.
    If *every* member is unavailable, the original order is used unchanged.

    Env knobs:
      HINDSIGHT_API_LLM_MEMBER_COOLDOWN      base cooldown seconds (default 30; 0 disables both signals)
      HINDSIGHT_API_LLM_MEMBER_COOLDOWN_MAX  cooldown cap seconds (default 300)
    """

    def __init__(self, n: int) -> None:
        self._base = float(os.getenv("HINDSIGHT_API_LLM_MEMBER_COOLDOWN", "30"))
        self._max = float(os.getenv("HINDSIGHT_API_LLM_MEMBER_COOLDOWN_MAX", "300"))
        self._down_until = [0.0] * n
        self._failures = [0] * n
        self._health_down = [False] * n
        self._lock = threading.Lock()

    @property
    def enabled(self) -> bool:
        return self._base > 0

    def filter_order(self, order: list[int]) -> list[int]:
        """Available members first (relative order kept), down members appended last."""
        if not self.enabled:
            return order
        now = time.monotonic()
        with self._lock:
            up = [i for i in order if not self._health_down[i] and self._down_until[i] <= now]
            down = [i for i in order if i not in up]
        return up + down if up else order

    def set_health(self, idx: int, up: bool) -> bool:
        """Update active-probe health; returns True when the state changed."""
        with self._lock:
            changed = self._health_down[idx] == up
            self._health_down[idx] = not up
            if up:
                # Endpoint reachable again: clear any request-failure cooldown so
                # a freshly started server is used immediately.
                self._failures[idx] = 0
                self._down_until[idx] = 0.0
        return changed

    def record_success(self, idx: int) -> None:
        with self._lock:
            self._failures[idx] = 0
            self._down_until[idx] = 0.0

    def record_failure(self, idx: int) -> float:
        """Mark ``idx`` failed; return the cooldown seconds applied."""
        if not self.enabled:
            return 0.0
        with self._lock:
            self._failures[idx] += 1
            cooldown = min(self._base * (2 ** (self._failures[idx] - 1)), self._max)
            self._down_until[idx] = time.monotonic() + cooldown
        return cooldown


class _HealthProber:
    """Background TCP prober for member endpoints (local overlay patch).

    Every ``HINDSIGHT_API_LLM_HEALTHCHECK_INTERVAL`` seconds (default 60; 0
    disables) attempts a TCP connect (1s timeout) to each member's
    ``base_url`` host:port and updates ``_MemberBreaker.set_health``. Members
    without a parseable ``base_url`` (e.g. codex) are never probed and stay
    governed by the passive cooldown only. Runs as a daemon thread; the first
    probe fires immediately so a down primary is demoted before real traffic.
    """

    def __init__(self, members: list["LLMProvider"], breaker: _MemberBreaker) -> None:
        self._interval = float(os.getenv("HINDSIGHT_API_LLM_HEALTHCHECK_INTERVAL", "60"))
        self._breaker = breaker
        self._targets: list[tuple[int, str, str, int]] = []  # (idx, label, host, port)
        for idx, member in enumerate(members):
            base_url = getattr(member, "base_url", None)
            if not base_url:
                continue
            parsed = urlparse(base_url)
            if not parsed.hostname:
                continue
            port = parsed.port or (443 if parsed.scheme == "https" else 80)
            label = f"{getattr(member, 'provider', '?')}/{getattr(member, 'model', '?')}"
            self._targets.append((idx, label, parsed.hostname, port))

    def start(self) -> None:
        if self._interval <= 0 or not self._targets or not self._breaker.enabled:
            return
        thread = threading.Thread(target=self._run, name="llm-health-prober", daemon=True)
        thread.start()

    def _run(self) -> None:
        while True:
            for idx, label, host, port in self._targets:
                try:
                    with socket.create_connection((host, port), timeout=1.0):
                        up = True
                except OSError:
                    up = False
                if self._breaker.set_health(idx, up):
                    logger.info(
                        "LLM member %d (%s) endpoint %s:%d is %s",
                        idx, label, host, port, "UP" if up else "DOWN",
                    )
            time.sleep(self._interval)


class _WeightedRoundRobin:
    """Smooth weighted round-robin scheduler (nginx SWRR).

    Produces a starting member index per request such that, over time, member
    ``i`` is chosen in proportion to ``weights[i]`` while keeping selections
    interleaved rather than bursty. Uniform weights degrade to plain round-robin.
    The tiny selection critical section is mutex-guarded so concurrent callers
    don't corrupt the running totals (they may still interleave, which only
    affects distribution, never correctness).
    """

    def __init__(self, weights: list[int]) -> None:
        self._weights = list(weights)
        self._current = [0] * len(weights)
        self._total = sum(weights)
        self._lock = threading.Lock()

    def next(self) -> int:
        with self._lock:
            best = 0
            for i, w in enumerate(self._weights):
                self._current[i] += w
                if self._current[i] > self._current[best]:
                    best = i
            self._current[best] -= self._total
            return best


class MultiLLMProvider:
    """Route LLM calls across multiple members per a failover / round-robin strategy."""

    def __init__(self, members: list[LLMProvider], strategy: LLMStrategyConfig) -> None:
        if not members:
            raise ValueError("MultiLLMProvider requires at least one member")
        self._members = members
        self._strategy = strategy

        weights = strategy.weights or [1] * len(members)
        if len(weights) != len(members):
            raise ValueError(
                f"LLM strategy 'weights' has {len(weights)} entries but the chain has "
                f"{len(members)} members (primary + indexed); they must match."
            )
        self._scheduler = _WeightedRoundRobin(weights)
        self._breaker = _MemberBreaker(len(members))
        _HealthProber(members, self._breaker).start()

    # ── routing ────────────────────────────────────────────────────────────────

    def _member_order(self) -> list[int]:
        """Indices to try, in order, for one request (healthy members first)."""
        n = len(self._members)
        if self._strategy.mode == LLM_STRATEGY_FAILOVER:
            order = list(range(n))
        else:
            start = self._scheduler.next()
            order = [(start + i) % n for i in range(n)]
        return self._breaker.filter_order(order)

    async def _dispatch(self, method_name: str, **kwargs: Any) -> Any:
        last_exc: BaseException | None = None
        order = self._member_order()
        for position, idx in enumerate(order):
            member = self._members[idx]
            try:
                result = await getattr(member, method_name)(**kwargs)
            except BaseException as e:  # noqa: BLE001 - re-raised unless it should fail over
                if not _should_failover(e):
                    raise
                last_exc = e
                cooldown = self._breaker.record_failure(idx)
                remaining = len(order) - position - 1
                logger.warning(
                    "LLM member %d (%s/%s) failed on %s: %s; cooldown %.0fs%s",
                    idx,
                    member.provider,
                    member.model,
                    method_name,
                    e,
                    cooldown,
                    f"; trying next member ({remaining} left)" if remaining else "; no members left",
                )
            else:
                self._breaker.record_success(idx)
                return result
        # All members failed; surface the last error (loop ran at least once).
        assert last_exc is not None
        raise last_exc

    async def call(self, messages: list[dict[str, Any]], **kwargs: Any) -> Any:
        return await self._dispatch("call", messages=messages, **kwargs)

    async def call_with_tools(
        self,
        messages: list[dict[str, Any]],
        tools: list[dict[str, Any]],
        **kwargs: Any,
    ) -> "LLMToolCallResult":
        return await self._dispatch("call_with_tools", messages=messages, tools=tools, **kwargs)

    # ── lifecycle ────────────────────────────────────────────────────────────────

    async def verify_connection(self) -> None:
        """Soft-verify every member with a 10s bound (overlay change).

        Upstream verifies the primary strictly and unbounded, which blocks server
        startup for the full LLM timeout when an intermittent primary (e.g. a
        laptop LM Studio) is down. With multiple members, availability is the
        chain's job — startup must not hinge on any single member, so every
        member is verified warn-only under a 10s cap.
        """
        for idx, member in enumerate(self._members):
            try:
                await asyncio.wait_for(member.verify_connection(), timeout=10.0)
            except Exception as e:  # noqa: BLE001 - soft verification
                logger.warning(
                    "LLM member %d (%s/%s) failed connection verification: %s. "
                    "It will be routed around at request time.",
                    idx,
                    member.provider,
                    member.model,
                    e,
                )

    async def cleanup(self) -> None:
        for member in self._members:
            await member.cleanup()

    def with_config(
        self,
        config: Any,
        *,
        bank_id: str | None = None,
        operation: str | None = None,
        metadata: dict[str, Any] | None = None,
    ) -> "ConfiguredLLMProvider":
        """Mirror ``LLMProvider.with_config`` so the strategy runs inside the
        per-operation configured wrapper (gemini-safety + trace contextvars wrap
        every member call)."""
        from .llm_trace import LLMTraceContext
        from .llm_wrapper import ConfiguredLLMProvider

        trace_ctx = None
        if bank_id is not None or operation is not None or metadata:
            trace_ctx = LLMTraceContext(
                bank_id=bank_id,
                operation=operation,
                metadata=dict(metadata or {}),
                trace_id=str(uuid.uuid4()),
                operation_span_id=str(uuid.uuid4()),
            )
        return ConfiguredLLMProvider(self, config.llm_gemini_safety_settings, trace_ctx)

    # ── attribute passthrough ────────────────────────────────────────────────────

    @property
    def members(self) -> list[LLMProvider]:
        return self._members

    def __getattr__(self, name: str) -> Any:
        # Anything not defined here (provider, model, api_key, base_url,
        # _provider_impl, mock helpers, batch helpers, ...) delegates to the
        # primary member so existing call sites keep working unchanged.
        return getattr(object.__getattribute__(self, "_members")[0], name)
