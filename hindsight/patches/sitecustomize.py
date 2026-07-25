"""Overlay: tolerate gaps in HINDSIGHT_API_*LLM_<n>_* member indices.

Upstream's ``_parse_llm_members`` stops scanning at the first index whose
``_PROVIDER`` is unset, so commenting out ``LLM_1`` silently drops ``LLM_2``
and later members. This runs at interpreter startup (before hindsight reads
config) and compacts each operation prefix's indices to be contiguous from 1,
preserving order. Indices without a ``PROVIDER`` are dropped entirely so a
stray ``API_KEY`` for a disabled member can never pair with the wrong provider
after renumbering.

Mounted at site-packages/sitecustomize.py via docker-compose.
"""

import os
import re

_PAT = re.compile(r"^HINDSIGHT_API_((?:RETAIN_|REFLECT_|CONSOLIDATION_)?)LLM_(\d+)_(.+)$")


def _compact_llm_member_indices() -> None:
    groups: dict[str, dict[int, dict[str, str]]] = {}
    for key in list(os.environ):
        m = _PAT.match(key)
        if m:
            groups.setdefault(m.group(1), {}).setdefault(int(m.group(2)), {})[m.group(3)] = key

    for prefix, by_index in groups.items():
        live = sorted(i for i in by_index if "PROVIDER" in by_index[i])
        if live == list(range(1, len(live) + 1)) and len(live) == len(by_index):
            continue
        values = {i: {s: os.environ[k] for s, k in by_index[i].items()} for i in by_index}
        for suffix_map in by_index.values():
            for key in suffix_map.values():
                del os.environ[key]
        for new_index, old_index in enumerate(live, 1):
            for suffix, value in values[old_index].items():
                os.environ[f"HINDSIGHT_API_{prefix}LLM_{new_index}_{suffix}"] = value


_compact_llm_member_indices()
