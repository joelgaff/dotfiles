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
