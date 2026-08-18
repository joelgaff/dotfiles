-- Personal keybinding overrides only.
--
-- Quattro's defaults now cover what used to be listed here by hand: terminal,
-- browser, nautilus, editor, tmux, spotify, cliamp, lazydocker, signal,
-- obsidian, 1password, grok, hey.com calendar/email, youtube, whatsapp,
-- google messages and x. See:
--   omarchy menu keybindings --print

-- Claude, in place of Omarchy's ChatGPT default.
hl.unbind("SUPER + SHIFT + A")
o.bind("SUPER + SHIFT + A", "Claude", { webapp = "https://claude.ai/" })

o.bind("SUPER + SHIFT + T", "Activity", { tui = "btop" })
o.bind("SUPER + SHIFT + L", "LazyVPN", os.getenv("HOME") .. "/.local/share/lazyvpn/bin/lazyvpn-menu")

-- Browser-style shortcuts forwarded to the focused window, so SUPER behaves
-- like Command does on macOS.
--
-- The down/up split and 50ms gap follow Omarchy's own clipboard bindings:
-- send_shortcut alone can leave synthetic key state stuck or repeating.
-- https://github.com/hyprwm/Hyprland/discussions/14099
local function send_shortcut(mods, key)
  return function()
    hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "down" }))

    hl.timer(function()
      hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "up" }))
    end, { timeout = 50, type = "oneshot" })
  end
end

-- SUPER+T becomes "new tab", so Omarchy's float toggle moves to SUPER+[.
hl.unbind("SUPER + T")
o.bind("SUPER + T", "Browser new tab", send_shortcut("CTRL", "T"))
o.bind("SUPER + bracketleft", "Toggle window floating", hl.dsp.window.float({ action = "toggle" }))

o.bind("SUPER + R", "Browser refresh", send_shortcut("CTRL", "R"))
o.bind("SUPER + A", "Select all", send_shortcut("CTRL", "A"))
o.bind("SUPER + Z", "Undo", send_shortcut("CTRL", "Z"), { repeating = true })
o.bind("SUPER + SHIFT + Z", "Redo", send_shortcut("CTRL SHIFT", "Z"), { repeating = true })
