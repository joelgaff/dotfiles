-- Framework 13.

hl.monitor({ output = "eDP-1", mode = "2880x1920@120", position = "auto-center-down", scale = 2 })
hl.monitor({ output = "DP-4", mode = "3840x2160@60", position = "auto-center-up", scale = 1.25 }) -- port 1, far left
hl.monitor({ output = "DP-3", mode = "3840x2160@60", position = "auto-center-up", scale = 1.25 }) -- port 2, near left

-- Docked layout: workspaces 1-5 on the external, 6-10 on the internal panel.
--
-- Only DP-3 is named. The old config declared every workspace against both
-- DP-3 and DP-4 hoping either would match, but a workspace rule takes a single
-- monitor and the last declaration simply wins -- so plugging into the other
-- port left the rules pointing at nothing. scripts/workspace-layout.sh does the
-- "whichever external is actually attached" part on every monitor event; these
-- rules are the boot-time baseline for the common case.
hl.workspace_rule({ workspace = "1", monitor = "DP-3", default = true, persistent = true })
for ws = 2, 5 do
  hl.workspace_rule({ workspace = tostring(ws), monitor = "DP-3", persistent = true })
end

-- Undocked, the 1-5 rules above name an absent monitor and Hyprland drops those
-- workspaces onto the internal panel, so 6-10 are left non-persistent to keep
-- the bar from showing ten workspaces on a laptop screen.
hl.workspace_rule({ workspace = "6", monitor = "eDP-1", default = true })
for ws = 7, 10 do
  hl.workspace_rule({ workspace = tostring(ws), monitor = "eDP-1" })
end
