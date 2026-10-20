#!/bin/bash

# Rebuild this setup on a fresh Omarchy machine: packages, dotfiles, tools,
# web apps, and shell plugins. Safe to run again; finished steps are skipped.
#
# First set up 1Password and turn on its SSH agent: the clone below and your
# own plugin repos come from GitHub over SSH.
#
#   git clone git@github.com:joelgaff/dotfiles.git ~/dotfiles
#   ~/dotfiles/setup/install.sh
#
# The lists it reads are written by `dots-save-packages` on the old machine.

set -uo pipefail

DOTFILES="$HOME/dotfiles"
SETUP="$DOTFILES/setup"
step() { printf '\n\033[1;34m==> %s\033[0m\n' "$1"; }

step "Packages"
# Only ask pacman for packages the repos still have, so one renamed package
# doesn't stop the rest.
mapfile -t available < <(comm -12 <(sort "$SETUP/pacman.txt") <(pacman -Slq | sort -u))
missing=$(comm -23 <(sort "$SETUP/pacman.txt") <(pacman -Slq | sort -u))
sudo pacman -Syu --needed --noconfirm "${available[@]}"
[ -n "$missing" ] && echo "Not in the repos any more (skipped): $missing"

step "AUR packages"
yay -S --needed --noconfirm - < "$SETUP/aur.txt"

step "Dotfiles"
# A fresh install already has its own copies of some of these files. --adopt
# moves them into the repo so stow can link, then checkout puts the repo's
# versions back. (Skipped when the repo has uncommitted changes of its own,
# so those aren't thrown away.)
cd "$DOTFILES"
dirty=$(git status --porcelain)
mapfile -t packages < <(find . -maxdepth 1 -mindepth 1 -type d \
  -not -name '.git' -not -name 'macos' -not -name 'setup' -printf '%f\n')
# --adopt can't take over a link Omarchy made (e.g. nvim's theme.lua), and
# one conflict stops stow linking anything, so remove those links first.
stow -n --adopt "${packages[@]}" 2>&1 \
  | sed -n 's/.*existing target is not owned by stow: //p' \
  | while read -r target; do [ -L "$HOME/$target" ] && rm "$HOME/$target"; done
stow --adopt "${packages[@]}" && [ -z "$dirty" ] && git checkout -- .

step "Tools (mise)"
mise install

step "Web apps"
apps="$HOME/.local/share/applications"
mkdir -p "$apps/icons"
cp "$SETUP/webapps/icons"/* "$apps/icons/"
for file in "$SETUP/webapps"/*.desktop; do
  sed "s|@HOME@|$HOME|g" "$file" > "$apps/$(basename "$file")"
done
update-desktop-database "$apps" 2>/dev/null || true

step "Shell plugins"
# Your own plugins are cloned into ~/Work and linked, so you can keep editing
# them; the rest install the normal way. Which ones are enabled, and where,
# comes from shell.json in the dotfiles.
plugins="$HOME/.config/omarchy/plugins"
mkdir -p "$plugins"
while read -r id url work; do
  [ -e "$plugins/$id" ] && continue
  if [ -n "$work" ]; then
    [ -d "$HOME/Work/$work" ] || git clone "$url" "$HOME/Work/$work"
    ln -s "$HOME/Work/$work" "$plugins/$id"
  else
    omarchy plugin add "$url" --yes
  fi
done < "$SETUP/plugins.txt"
omarchy-shell shell rescanPlugins 2>/dev/null || true

step "Services and groups"
for unit in $(cat "$SETUP/services.txt"); do
  systemctl cat "$unit" >/dev/null 2>&1 && sudo systemctl enable "$unit" 2>/dev/null
done
for group in $(cat "$SETUP/groups.txt"); do
  getent group "$group" >/dev/null && sudo usermod -aG "$group" "$USER"
done

step "Done"
cat <<'EOF'
Still to do by hand:
  - Sign in: 1Password (turn on its SSH agent + CLI integration), Dropbox,
    Tailscale (sudo tailscale up), Chromium/web apps, Signal, Spotify, etc.
  - Laptop-only /etc settings in ~/dotfiles/systemd are NOT applied (lid, hibernate).
  - Check monitor layout in ~/.config/hypr/monitors.lua, then reboot.
EOF
