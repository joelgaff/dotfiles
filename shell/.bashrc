# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'
alias het='ssh deploy@5.161.58.238'

# Dotfiles management
df() {
  if [[ "$1" == "--help" ]]; then
    echo "Dotfiles commands:"
    echo "  df          dotfiles - cd into ~/dotfiles"
    echo "  df --help   show this menu"
    echo "  dfs         dotfiles status - git status"
    echo "  dfc <msg>   dotfiles commit - git add all + commit with message"
    echo "  dfp         dotfiles push - git push"
  else
    cd ~/dotfiles
  fi
}
dfc() {
  cd ~/dotfiles && git add . && git commit -m "$*"
}
alias dfs='git -C ~/dotfiles status'
alias dfp='cd ~/dotfiles && git push'
export PATH="$HOME/.local/bin:$HOME/.gem/ruby/3.4.0/bin:$HOME/.gem/ruby/3.4.5/bin:$PATH"
