-- MacBook Pro running Omarchy.
-- The internal panel is failing, so it stays disabled and everything lives on
-- the external. This box runs largely headless as an OpenClaw gateway, so
-- having no display when undocked is fine. Re-enable the line below if the
-- panel is ever repaired or you need it in a pinch.

hl.monitor({ output = "eDP-1", disabled = true })
-- hl.monitor({ output = "eDP-1", mode = "2880x1800@60", position = "0x0", scale = 2 })

-- 1-5 on the external, matching framework13. There is no 6-10 half here: that
-- is the laptop panel's, and this one is disabled, so those workspaces fall
-- through to the catch-all rule in monitors.lua and land on the external too.
hl.workspace_rule({ workspace = "1", monitor = "DP-1", default = true, persistent = true })
for ws = 2, 5 do
  hl.workspace_rule({ workspace = tostring(ws), monitor = "DP-1", persistent = true })
end

-- Laptop watchers (moved from autostart.lua so they don't run on the beelink).
-- Keeps workspaces 1-5 on the external and 6-10 on the internal panel as
-- monitors come and go. See scripts/workspace-layout-watch.sh.
o.launch_on_start(os.getenv("HOME") .. "/.config/hypr/scripts/workspace-layout-watch.sh")

-- Hides Chromium's "is sharing your screen" bar when Omarchy's map-time rule
-- misses it. See scripts/share-bar-hide-watch.sh.
o.launch_on_start(os.getenv("HOME") .. "/.config/hypr/scripts/share-bar-hide-watch.sh")

-- MacBook internal keyboard: Command already lands on Super, so don't swap.
hl.device({ name = "apple-spi-keyboard", kb_layout = "us", kb_options = "compose:caps" })
