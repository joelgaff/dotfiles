-- MacBook Pro running Omarchy.
-- The internal panel is failing, so it stays disabled and everything lives on
-- the external. This box runs largely headless as an OpenClaw gateway, so
-- having no display when undocked is fine. Re-enable the line below if the
-- panel is ever repaired or you need it in a pinch.

hl.monitor({ output = "eDP-1", disabled = true })
-- hl.monitor({ output = "eDP-1", mode = "2880x1800@60", position = "0x0", scale = 2 })

-- monitors.lua pins workspaces 1-5 to eDP-1 for both machines and runs before
-- this file, so re-point them at the external here. framework13 keeps the
-- shared rule; only this host overrides it.
hl.workspace_rule({ workspace = "1", monitor = "DP-1", default = true, persistent = true })
for ws = 2, 5 do
  hl.workspace_rule({ workspace = tostring(ws), monitor = "DP-1", persistent = true })
end
