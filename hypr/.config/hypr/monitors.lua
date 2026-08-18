-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

-- Monitor and workspace layout is machine-specific, so it lives in
-- hosts/<hostname>.lua. This repo is shared by framework13 and mbp-omarchy;
-- before Quattro both machines' monitors sat in one file with the inactive
-- one commented out, which broke on every upgrade.

local function hostname()
  local f = io.open("/etc/hostname")
  if not f then
    return nil
  end
  local name = f:read("l")
  f:close()
  return name
end

hl.env("GDK_SCALE", "2")

-- Fallback for any output the host file doesn't name.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

-- Workspaces 1-5 live on the internal display on both machines.
hl.workspace_rule({ workspace = "1", monitor = "eDP-1", default = true, persistent = true })
for ws = 2, 5 do
  hl.workspace_rule({ workspace = tostring(ws), monitor = "eDP-1", persistent = true })
end

local host = hostname()
if host then
  local ok, err = pcall(require, "hypr.hosts." .. host)
  if not ok then
    -- Unknown machine: the fallback monitor rule above still gives a display.
    print("hypr: no host config for '" .. host .. "': " .. tostring(err))
  end
end

local scripts = os.getenv("HOME") .. "/.config/hypr/scripts"

-- Manual internal-display toggle. Wraps omarchy-hyprland-monitor-internal to
-- also move workspaces 1-5 to the external and mask fprintd.
o.bind("SUPER + CTRL + M", "Toggle internal monitor", scripts .. "/toggle-internal-monitor.sh")

-- Omarchy handles the lid itself now, but without fprintd coupling or the
-- suspend-then-hibernate fallback for an undocked lid close, so take it over.
hl.unbind("switch:on:Lid Switch")
hl.unbind("switch:off:Lid Switch")
o.bind("switch:on:Lid Switch", nil, scripts .. "/clamshell.sh close", { locked = true })
o.bind("switch:off:Lid Switch", nil, scripts .. "/clamshell.sh open", { locked = true })
