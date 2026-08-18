-- Personal input overrides. Uncommented settings replace Omarchy's defaults.

hl.config({
  input = {
    kb_layout = "us",
    -- compose:caps = Caps Lock as Compose. altwin:swap_alt_win suits the
    -- external Lofree; the MacBook's own keyboard is exempted below.
    kb_options = "compose:caps, altwin:swap_alt_win",
    repeat_rate = 40,
    repeat_delay = 600,
    touchpad = {
      natural_scroll = true,
      clickfinger_behavior = true,
      scroll_factor = 0.4,
    },
  },
})

-- App-specific touchpad scroll speeds.
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })

-- MacBook internal keyboard: Command already lands on Super, so don't swap.
hl.device({ name = "apple-spi-keyboard", kb_layout = "us", kb_options = "compose:caps" })

-- Lofree Flow84, under each name it registers as.
for _, name in ipairs({ "compx-flow84@lofree", "compx-flow84@lofree-1", "compx-flow84@lofree-2" }) do
  hl.device({ name = name, kb_layout = "us", kb_options = "compose:caps, altwin:swap_alt_win" })
end
