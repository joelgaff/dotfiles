# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
# /etc/omarchy.conf is written by omarchy-dev-link. When absent, force the
# package default instead of preserving a stale inherited dev-link value before
# we decide which rc file to source.
if [[ -f /etc/omarchy.conf ]]; then
  source /etc/omarchy.conf
  export OMARCHY_PATH="${OMARCHY_PATH:-/usr/share/omarchy}"
else
  export OMARCHY_PATH=/usr/share/omarchy
fi
source "$OMARCHY_PATH/default/bash/rc"

# Cross-platform aliases + functions (shared with .zshrc on macOS)
[ -f ~/.aliases ] && source ~/.aliases

export PATH="$HOME/.local/bin:$HOME/.gem/ruby/3.4.0/bin:$HOME/.gem/ruby/3.4.5/bin:$PATH"

# LazyVPN
export PATH="$HOME/.local/share/lazyvpn/bin:$PATH"

# OpenClaw Completion
[ -f "/home/joel/.openclaw/completions/openclaw.bash" ] && source "/home/joel/.openclaw/completions/openclaw.bash"
