# macOS zsh config.

# Cross-platform aliases + functions (shared with .bashrc on Linux)
[ -f ~/.aliases ] && source ~/.aliases

# PATH
export PATH="$HOME/.local/bin:$PATH"
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
export PATH="$HOME/.codeium/windsurf/bin:$PATH"

# rbenv (Ruby version manager)
command -v rbenv >/dev/null && eval "$(rbenv init - zsh)"

# Starship prompt
command -v starship >/dev/null && eval "$(starship init zsh)"

# Editor (TextMate)
export EDITOR="/usr/local/bin/mate -w"
