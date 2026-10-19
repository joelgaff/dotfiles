# Dotfiles

My personal configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Overview

This repo tracks user-level config for an [Omarchy](https://omarchy.org) setup (Arch Linux + Hyprland). Omarchy manages the base system — window manager, themes, default apps — but leaves `~/.config/` and `~/.local/bin/` alone. That's where these dotfiles live.

`omarchy update` mostly leaves these alone, but not always: its migrations rewrite
user configs with `jq >tmp && mv tmp config`, and that `mv` replaces a stow symlink
with a plain file. The config keeps working while this repo quietly stops tracking it.
A `post-update` hook re-links everything afterwards — see [Config Drift](#config-drift).

## Packages

- **shell** - Bash configuration (.bashrc, .bash_profile, .bash_logout, .XCompose)
- **hypr** - Hyprland compositor configuration
- **nvim** - Neovim text editor
- **git** - Git configuration
- **starship** - Starship shell prompt
- **mise** - Mise version manager
- **ghostty** - Ghostty terminal emulator
- **alacritty** - Alacritty terminal emulator
- **omarchy** - Omarchy (Quattro) Quickshell settings — bar layout, idle timers, the
  `joel.display-off` shell plugin, and the `post-update` hook that repairs stow drift
- **bin** - User scripts (`omarchy-export`, `omarchy-import`, `dots-save-packages`) in `~/.local/bin`
- **setup** - Not stowed: `install.sh` and the package/plugin/web app lists it reads (see [Fresh Machine Setup](#fresh-machine-setup))
- **qmd** - [QMD](https://github.com/nickarrow/qmd) local markdown search — systemd timer for daily re-indexing
- **wayland** - Keeps Spotify off XWayland so fractional monitor scaling stays sharp.
  Only Spotify needs this: Omarchy's `envs.lua` already exports
  `ELECTRON_OZONE_PLATFORM_HINT`, which covers every Electron app, but Spotify
  embeds CEF and ignores it
- **systemd** - System-level config in `/etc/` — logind, sudoers, UPower (not managed by
  Stow — see [System Configuration](#system-configuration))

## How It Works

GNU Stow creates symlinks from this repo into your home directory. The files live here; the symlinks make them appear where apps expect them:

- `dotfiles/shell/.bashrc` → `~/.bashrc`
- `dotfiles/ghostty/.config/ghostty/config` → `~/.config/ghostty/config`
- `dotfiles/bin/.local/bin/` → `~/.local/bin/`

When you edit a config file at its normal path (e.g. `~/.config/ghostty/config`), you're actually editing the file in this repo. Changes can be committed immediately.

The `bin` package adds `omarchy-export` and `omarchy-import` to `~/.local/bin`, which is on your PATH via `.bashrc`. Use `omarchy-export` to snapshot your current setup, and `omarchy-import` to restore it on a fresh machine.

## Fresh Machine Setup

1. Install Omarchy, then set up 1Password and turn on its SSH agent (the clone
   and your own plugin repos come from GitHub over SSH).

2. Clone this repo and run the installer:
   ```bash
   git clone git@github.com:joelgaff/dotfiles.git ~/dotfiles
   ~/dotfiles/setup/install.sh
   ```
   It installs your packages (pacman + AUR), stows every package here (the
   repo's versions win over the fresh install's defaults), runs `mise install`,
   restores your web apps, and installs your shell plugins. It's safe to run
   again. At the end it lists what still needs doing by hand (sign-ins, monitors).

   On **macOS only**, stow the Mac-specific packages instead:
   ```bash
   stow -d macos -t ~ skhd
   ```
   These live under `macos/` so `stow */` on Linux never picks them up.

### Exact Copy of Another Machine

To make a new machine just like an old one (browser sign-ins, keys, documents,
`~/Work`, every setting), not only the packages:

1. On the old machine: `sudo ufw allow in on tailscale0 to any port 22 proto tcp`
   and quit your browser.
2. Install Omarchy on the new one with the **same username and password**.
3. On the new machine:
   ```bash
   bash <(curl -fsSL https://raw.githubusercontent.com/joelgaff/dotfiles/quattro/setup/clone-from.sh) framework13
   ```

`setup/clone-from.sh` joins Tailscale, copies the whole home folder over it, then runs
`install.sh`. Hostname, Tailscale identity, and the Dropbox/1Password/Synology
device links stay the new machine's own; sign in to those again.

## Managing Dotfiles

Defined in `shell/.aliases`, which both `.bashrc` and `.zshrc` source:

```bash
dots                    # cd into ~/dotfiles
dots --help             # list these commands
dotss                   # git status
dotsc "Update hypr"     # git add -A + commit
dotsc                   # same, but suggests a message from the diff
dotsp                   # git push
```

`dotcheck` reports uncommitted, unpushed, or unpulled work with a fix hint for
each. It runs itself once a day at shell startup, gated on `~/.dotcheck-stamp`.

### Other Aliases

```bash
het        # ssh deploy@5.161.58.238
gateway    # ssh gateway (Tailscale host, see ~/.ssh/config)
bcc        # basecamp
lg         # lazygit
t3         # things3
```

### Saving What's Installed

Run `dots-save-packages` before setting up a new machine (and now and then) to
refresh the snapshot in `setup/` that `setup/install.sh` reads, then commit it:

- `pacman.txt` / `aur.txt`: packages you installed (kernel, bootloader, CPU and
  GPU drivers are left out; the Omarchy installer picks those per machine)
- `plugins.txt`: Omarchy shell plugins (yours get cloned into `~/Work`)
- `webapps/`: web apps you added, with their icons

### System Configuration

The `systemd/` directory contains system-level config that lives in `/etc/` and can't be
managed by Stow. Despite the name it is not all systemd — it also holds `sudoers.d/` and
UPower config. These are tracked here for version control and deployed manually:

```bash
sudo cp -rT ~/dotfiles/systemd/etc /etc
```

The `-T` matters. Without it, `cp -r src/ /etc/` copies the *directory* rather than its
contents and you get an inert `/etc/etc/` instead of the deploy you wanted.

What's in there:

- `systemd/logind.conf.d/lid.conf` — leaves lid handling to Hyprland's `clamshell.sh`
- `sudoers.d/clamshell` — lets that script run without a password prompt
- `UPower/UPower.conf.d/90-critical-hibernate.conf` — hibernates at 7% battery so an
  unattended machine saves its session instead of dying with it. `upowerd` already polls
  the battery for everything else, so nothing custom monitors it.

After changing the UPower drop-in, `sudo systemctl restart upower`.

### Config Drift

Omarchy migrations replace stowed files with plain copies (see
[Overview](#overview)), which silently unlinks them from this repo. `shell.json` drifted
that way once and lost a lock-timeout change before anyone noticed.

`omarchy/.config/omarchy/hooks/post-update.d/restow-dotfiles` runs after every
`omarchy update`. It re-stows every package with `--adopt`: anything still linked is left
alone, anything that came unlinked has its live content pulled back into this repo and its
symlink restored. If it adopted anything, it sends a notification — review with
`cd ~/dotfiles && git diff` before committing.

To check by hand at any time:

```bash
cd ~/dotfiles && stow --adopt $(ls -d */ | grep -vxE 'macos/|setup/') && git status
```

### Adding a New Package

1. Create the package with mirrored directory structure:
   ```bash
   mkdir -p ~/dotfiles/newpackage/.config/newapp
   ```

2. Move your config into it:
   ```bash
   mv ~/.config/newapp/config.toml ~/dotfiles/newpackage/.config/newapp/
   ```

3. Stow it:
   ```bash
   stow newpackage
   ```

### Removing a Package

```bash
stow -D packagename
```
