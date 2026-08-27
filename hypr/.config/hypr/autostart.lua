-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- Keeps workspaces 1-5 on the external and 6-10 on the internal panel as
-- monitors come and go. See scripts/workspace-layout-watch.sh.
o.launch_on_start(os.getenv("HOME") .. "/.config/hypr/scripts/workspace-layout-watch.sh")
