-- Framework 13.

hl.monitor({ output = "eDP-1", mode = "2880x1920@120", position = "auto-center-down", scale = 2 })
hl.monitor({ output = "DP-4", mode = "3840x2160@60", position = "auto-center-up", scale = 1.5 }) -- port 1, far left
hl.monitor({ output = "DP-3", mode = "3840x2160@60", position = "auto-center-up", scale = 1.5 }) -- port 2, near left

-- Workspaces 6-10 on whichever external is attached. Carried over verbatim
-- from the pre-Quattro monitors.conf, which declared both DP-3 and DP-4 for
-- each of 6-10; worth revisiting if the assignment ever looks wrong.
for ws = 6, 10 do
  hl.workspace_rule({ workspace = tostring(ws), monitor = "DP-3" })
end
for ws = 6, 10 do
  hl.workspace_rule({ workspace = tostring(ws), monitor = "DP-4" })
end
