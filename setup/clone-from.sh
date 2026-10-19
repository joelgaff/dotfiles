#!/bin/bash

# Make this fresh Omarchy machine a copy of another one: the whole home folder
# (settings, browser sign-ins, keys, documents, projects), then the same
# packages, plugins and services via install.sh. What identifies a machine
# stays this one's own: hostname, Tailscale, and the Dropbox, 1Password and
# Synology Drive device links (sign in to those again).
#
# Install Omarchy with the SAME username and password as the old machine (the
# password unlocks the copied keyring that holds browser sign-ins), then run:
#
#   bash <(curl -fsSL https://raw.githubusercontent.com/joelgaff/dotfiles/quattro/setup/clone-from.sh) framework13
#
# The old machine must be awake, on Tailscale, and accept SSH on it:
#   sudo ufw allow in on tailscale0 to any port 22 proto tcp
# Safe to run again; the copy picks up where it stopped.

set -euo pipefail

FROM=${1:?usage: clone-from.sh <old machine name on Tailscale>}
step() { printf '\n\033[1;34m==> %s\033[0m\n' "$1"; }

step "Tailscale"
sudo pacman -S --needed --noconfirm tailscale rsync
sudo systemctl enable --now tailscaled
tailscale status >/dev/null 2>&1 || sudo tailscale up   # prints a sign-in link

# One SSH connection for everything below, so the password is asked once.
ssh_opts="-o ControlMaster=auto -o ControlPath=$HOME/.ssh-clone-%C -o ControlPersist=30m"
step "Connecting to $FROM (enter $FROM's password)"
ssh $ssh_opts "$USER@$FROM" true

excludes=(
  --exclude=/.cache/ --exclude=/.local/share/Trash/
  --exclude=/.local/share/omarchy/            # belongs to this machine's Omarchy version
  --exclude=/.dropbox/ --exclude=/.config/1Password/ --exclude=/.1password/
  --exclude=/.SynologyDrive/                  # device links: sign in again instead
  --exclude=/dropbox-safety-backup/ --exclude=/.config.pre-stow.bak/
  --exclude='Singleton*'                      # browser locks naming the old machine
  --exclude=/.ssh-clone-*
)

# Dropbox is huge. Copy it over the network if it fits (much faster than
# Dropbox downloading it); otherwise leave it for Dropbox to sync.
need=$(ssh $ssh_opts "$USER@$FROM" 'du -sb ~/Dropbox 2>/dev/null | cut -f1')
free=$(df --output=avail -B1 "$HOME" | tail -1)
if (( ${need:-0} + 200 * 1024**3 > free )); then
  echo "Not enough room to copy Dropbox; Dropbox will sync it after you sign in."
  excludes+=(--exclude=/Dropbox/)
fi

step "Copying home folder from $FROM (can take hours; Ethernet helps)"
rsync -aH --no-specials --no-devices --partial --info=progress2 \
  -e "ssh $ssh_opts" "${excludes[@]}" "$USER@$FROM:" "$HOME/" \
  || [ $? -eq 24 ]   # 24 = some files changed while copying, which is fine
ssh $ssh_opts -O exit "$USER@$FROM" 2>/dev/null || true

step "Packages, plugins, services"
"$HOME/dotfiles/setup/install.sh"

cat <<EOF

All copied. Reboot, then sign in to 1Password (on $FROM: 1Password >
Settings > Accounts > "Set up another device"), Dropbox and Synology Drive.
Docker images and local PostgreSQL databases live outside the home folder and
were not copied. To close SSH on $FROM again:
  sudo ufw delete allow in on tailscale0 to any port 22 proto tcp
EOF
