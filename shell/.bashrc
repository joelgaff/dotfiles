# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Cross-platform aliases + functions (shared with .zshrc on macOS)
[ -f ~/.aliases ] && source ~/.aliases

export PATH="$HOME/.local/bin:$HOME/.gem/ruby/3.4.0/bin:$HOME/.gem/ruby/3.4.5/bin:$PATH"

# LazyVPN
export PATH="$HOME/.local/share/lazyvpn/bin:$PATH"
