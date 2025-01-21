local b = require("utils.background")
local h = require("utils.helpers")
local wezterm = require("wezterm")
local act = wezterm.action
-- local assets = wezterm.config_dir .. "/assets"
local config = wezterm.config_builder()

-- set this to true to enable fancy background
local fancy = false

config.max_fps = 120
config.prefer_egl = true

config.colors = {
  cursor_bg = "#f5c06f",
  cursor_border = "#f5c06f",
  indexed = { [239] = "lightslategray" },
}

config.macos_window_background_blur = 30
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"
config.window_close_confirmation = "AlwaysPrompt" -- @TODO depending if running in tmux emulation or not
config.native_macos_fullscreen_mode = true
config.use_fancy_tab_bar = false
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

-- font config
config.font = wezterm.font("Monaspace Neon", { weight = "Regular" })
config.font_rules = {
  {
    intensity = "Normal",
    italic = true,
    font = wezterm.font("Monaspace Radon", { weight = "Regular" }),
  },
  {
    intensity = "Bold",
    italic = false,
    font = wezterm.font("Monaspace Neon", { weight = "ExtraBold" }),
  },
  {
    intensity = "Bold",
    italic = true,
    font = wezterm.font("Monaspace Radon", { weight = "ExtraBold" }),
  },
}
config.harfbuzz_features = { "calt", "dlig", "clig=1", "ss01", "ss02", "ss03", "ss04", "ss05", "ss06", "ss07", "ss08" }
config.font_size = 14
config.line_height = 1.1
config.adjust_window_size_when_changing_font_size = false

-- keys config
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = false

config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

local resizeStep = 5
config.key_tables = {
  -- Defines the keys that are active in our resize-pane mode.
  -- Since we're likely to want to make multiple adjustments,
  -- we made the activation one_shot=false. We therefore need
  -- to define a key assignment for getting out of this mode.
  -- 'resize_pane' here corresponds to the name="resize_pane" in
  -- the key assignments above.
  resize_pane = {
    { key = "H", mods = "SHIFT", action = act.AdjustPaneSize({ "Left", resizeStep }) },
    { key = "L", mods = "SHIFT", action = act.AdjustPaneSize({ "Right", resizeStep }) },
    { key = "K", mods = "SHIFT", action = act.AdjustPaneSize({ "Up", resizeStep }) },
    { key = "J", mods = "SHIFT", action = act.AdjustPaneSize({ "Down", resizeStep }) },
  },
  change_tab = {
    { key = "h", mods = "CTRL", action = act.ActivateTabRelative(-1) },
    { key = "l", mods = "CTRL", action = act.ActivateTabRelative(1) },
  },
}
local activateResize = act.ActivateKeyTable({
  name = "resize_pane",
  one_shot = false,
  timeout_milliseconds = 1000,
})
local activateChangeTab = act.ActivateKeyTable({
  name = "change_tab",
  one_shot = false,
  timeout_milliseconds = 1000,
})
config.keys = {
  {
    key = "H",
    mods = "LEADER|SHIFT",
    action = act.Multiple({
      act.AdjustPaneSize({ "Left", resizeStep }),
      activateResize,
    }),
  },
  {
    key = "J",
    mods = "LEADER|SHIFT",
    action = act.Multiple({
      act.AdjustPaneSize({ "Down", resizeStep }),
      activateResize,
    }),
  },
  {
    key = "K",
    mods = "LEADER|SHIFT",
    action = act.Multiple({
      act.AdjustPaneSize({ "Up", resizeStep }),
      activateResize,
    }),
  },
  {
    key = "L",
    mods = "LEADER|SHIFT",
    action = act.Multiple({
      act.AdjustPaneSize({ "Right", resizeStep }),
      activateResize,
    }),
  },
  {
    mods = "LEADER",
    key = '"',
    action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
  },
  {
    mods = "LEADER",
    key = "%",
    action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },
  {
    mods = "LEADER",
    key = "z",
    action = act.TogglePaneZoomState,
  },
  {
    mods = "LEADER|CTRL",
    key = "h",
    action = act.Multiple({
      act.ActivateTabRelative(-1),
      activateChangeTab,
    }),
  },
  {
    mods = "LEADER|CTRL",
    key = "l",
    action = act.Multiple({
      act.ActivateTabRelative(1),
      activateChangeTab,
    }),
  },
  {
    mods = "LEADER",
    key = "N",
    action = act.SpawnTab("CurrentPaneDomain"),
  },
  {
    key = "Escape",
    mods = "LEADER",
    action = act.ActivateCopyMode,
  },
  {
    key = "s",
    mods = "LEADER",
    action = act.ShowLauncherArgs({
      flags = "FUZZY|WORKSPACES",
    }),
  },
  {
    key = "g",
    mods = "LEADER",
    action = act.SwitchToWorkspace({
      name = "lazygit",
      spawn = {
        args = { "/opt/homebrew/bin/lazygit" },
      },
    }),
  },
}

if h.is_dark then
  -- local custom = wezterm.color.get_builtin_schemes()["Catppuccin Macchiato"]
  -- -- set a custom, darker background color for Macchiato
  -- custom.background = "#0b0b12"

  -- override the Catppuccin Macchiato color scheme
  -- config.color_schemes = {
  --   ["Catppuccin Macchiato"] = custom,
  -- }

  -- and use the custom color scheme
  -- config.color_scheme = "Catppuccin Macchiato"
  config.color_scheme = "Catppuccin Macchiato"
  config.set_environment_variables = {
    THEME_FLAVOUR = "macchiato",
  }
  if fancy then
    config.background = {
      b.get_background(),
      -- b.get_wallpaper(assets .. "/cage.jpg"),
      -- b.get_animation(assets .. "/pulsing.gif"),
    }
  end
else
  config.color_scheme = "Catppuccin Latte"
  config.window_background_opacity = 1
  config.set_environment_variables = {
    THEME_FLAVOUR = "latte",
  }
  config.background = {
    -- b.get_background(),
  }
end

wezterm.plugin.require("https://gitlab.com/xarvex/presentation.wez").apply_to_config(config)

local smart_splits = wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")
-- you can put the rest of your Wezterm config here
smart_splits.apply_to_config(config, {
  -- the default config is here, if you'd like to use the default keys,
  -- you can omit this configuration table parameter and just use
  -- smart_splits.apply_to_config(config)

  -- directional keys to use in order of: left, down, up, right
  direction_keys = { "h", "j", "k", "l" },
  -- if you want to use separate direction keys for move vs. resize, you
  -- can also do this:
  -- modifier keys to combine with direction_keys
  modifiers = {
    move = "CTRL", -- modifier to use for pane movement, e.g. CTRL+h to move left
    -- resize = "LEADER", -- modifier to use for pane resize, e.g. META+h to resize to the left
  },
  -- log level to use: info, warn, error
  log_level = "info",
})

-- neovim zen-mode plugin
wezterm.on("user-var-changed", function(window, pane, name, value)
  local overrides = window:get_config_overrides() or {}
  if name == "ZEN_MODE" then
    local incremental = value:find("+")
    local number_value = tonumber(value)
    if incremental ~= nil then
      while number_value > 0 do
        window:perform_action(wezterm.action.IncreaseFontSize, pane)
        number_value = number_value - 1
      end
    elseif number_value < 0 then
      window:perform_action(wezterm.action.ResetFontSize, pane)
      overrides.font_size = nil
    else
      overrides.font_size = number_value
    end
  end
  window:set_config_overrides(overrides)
end)

return config
