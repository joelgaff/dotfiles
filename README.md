# Dotfiles

My personal configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Overview

This repository contains configuration files for my Linux setup (Arch Linux with Hyprland). Dotfiles are organized into packages and symlinked to their appropriate locations using GNU Stow.

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

## Installation

### Prerequisites

```bash
sudo pacman -S stow git
```

### Setup on a New Machine

1. Clone this repository:
   ```bash
   git clone git@github.com:joelgaff/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. Stow the packages you want (or all of them):
   ```bash
   # Stow all packages
   stow */

   # Or stow individual packages
   stow shell
   stow hypr
   stow nvim
   # ... etc
   ```

3. Reload your shell:
   ```bash
   source ~/.bashrc
   ```

## How It Works

GNU Stow creates symlinks from this repository to your home directory. For example:
- `~/dotfiles/shell/.bashrc` → `~/.bashrc`
- `~/dotfiles/hypr/.config/hypr/` → `~/.config/hypr/`
- `~/dotfiles/nvim/.config/nvim/` → `~/.config/nvim/`

This means when you edit your config files normally (like `~/.bashrc`), you're actually editing the files in this repository. Any changes can be immediately committed and pushed.

## Usage

### Updating Dotfiles

I've set up some convenient bash functions/aliases for managing this repo:

```bash
# Jump to dotfiles directory
df

# Commit changes with a message
dfc Update hypr keybindings

# Push to GitHub
dfp

# Or chain them together
dfc Update configs && dfp
```

### Adding New Packages

1. Create a new package directory with the proper structure:
   ```bash
   cd ~/dotfiles
   mkdir -p newpackage/.config/newapp
   ```

2. Copy your config files into the package:
   ```bash
   cp -r ~/.config/newapp/* newpackage/.config/newapp/
   ```

3. Remove the original and stow the package:
   ```bash
   rm -rf ~/.config/newapp
   stow newpackage
   ```

### Removing a Package

```bash
cd ~/dotfiles
stow -D packagename
```

## Credits

Setup inspired by [Typecraft's dotfiles tutorial](https://typecraft.dev/tutorial/never-lose-your-configs-again).
