-- Beelink SER8 home server.
-- Runs unattended: the BIOS powers it back on after a power failure, the TPM
-- unlocks the disk, and SDDM logs straight in. Lock right after that so the
-- box isn't left open at the console. Services and SSH keep running behind it.
--
-- The lock screen is drawn by the Omarchy shell, which isn't up yet when
-- Hyprland starts, so wait for it to answer a ping (up to 30s) first.
o.exec_on_start("bash -c 'for i in $(seq 60); do omarchy-shell shell ping >/dev/null 2>&1 && break; sleep 0.5; done; omarchy-system-lock'")
