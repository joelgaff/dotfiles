# Dotfiles

My personal configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Overview

This repo tracks user-level config for an [Omarchy](https://omarchy.org) setup (Arch Linux + Hyprland). Omarchy manages the base system — window manager, themes, default apps — but leaves `~/.config/` and `~/.local/bin/` alone. That's where these dotfiles live.

Running `omarchy-update` will never overwrite anything tracked here.

## Packages

- **shell** - Bash configuration (.bashrc, .bash_profile, .bash_logout, .XCompose)
- **hypr** - Hyprland compositor configuration
- **nvim** - Neovim text editor
- **git** - Git configuration
- **starship** - Starship shell prompt
- **mise** - Mise version manager
- **kitty** - Kitty terminal emulator
- **ghostty** - Ghostty terminal emulator
- **alacritty** - Alacritty terminal emulator
- **waybar** - Waybar status bar
- **walker** - Walker application launcher
- **bin** - User scripts (`omarchy-export`, `omarchy-import`, `dots-save-packages`) in `~/.local/bin`

## How It Works

GNU Stow creates symlinks from this repo into your home directory. The files live here; the symlinks make them appear where apps expect them:

- `dotfiles/shell/.bashrc` → `~/.bashrc`
- `dotfiles/walker/.config/walker/config.toml` → `~/.config/walker/config.toml`
- `dotfiles/bin/.local/bin/` → `~/.local/bin/`

When you edit a config file at its normal path (e.g. `~/.config/walker/config.toml`), you're actually editing the file in this repo. Changes can be committed immediately.

The `bin` package adds `omarchy-export` and `omarchy-import` to `~/.local/bin`, which is on your PATH via `.bashrc`. Use `omarchy-export` to snapshot your current setup, and `omarchy-import` to restore it on a fresh machine.

## Fresh Machine Setup

1. Install Omarchy, then clone this repo:
   ```bash
   git clone git@github.com:joelgaff/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. Stow all packages:
   ```bash
   stow */
   ```

3. Reload your shell:
   ```bash
   source ~/.bashrc
   ```

4. Run `omarchy-import` to restore any additional settings from a previous export.

## Managing Dotfiles

```bash
# Jump to dotfiles directory
df

# Commit changes with a message
dfc Update hypr keybindings

# Push to GitHub
dfp
```

### Saving AUR Packages

Run `dots-save-packages` to save a list of your AUR packages to `aur-packages.txt` in the repo root. This makes it easy to reinstall them on a fresh machine:

```bash
# Save current AUR packages
dots-save-packages

# On a new machine, install them with your AUR helper
yay -S - < ~/dotfiles/aur-packages.txt
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
