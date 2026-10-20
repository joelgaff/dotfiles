-- Personal input overrides. Uncommented settings replace Omarchy's defaults.

hl.config({
  input = {
    kb_layout = "us",
    -- compose:caps = Caps Lock as Compose. altwin:swap_alt_win puts Super on
    -- the key next to the spacebar, Mac-style, on every keyboard. Apple
    -- keyboards would arrive with Command already on Super, so
    -- systemd/etc/modprobe.d/90-hid-apple-swap.conf has the kernel report
    -- them in PC order first; then this one swap fits them too, including
    -- keyboards plugged in or paired later.
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

-- MacBook internal keyboard: driven by applespi, not hid_apple, so the
-- modprobe option doesn't reach it and Command already lands on Super.
hl.device({ name = "apple-spi-keyboard", kb_layout = "us", kb_options = "compose:caps" })
