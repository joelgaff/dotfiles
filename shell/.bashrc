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
dots() {
  if [[ "$1" == "--help" ]]; then
    echo "Dotfiles commands:"
    echo "  dots          dotfiles - cd into ~/dotfiles"
    echo "  dots --help   show this menu"
    echo "  dotss         dotfiles status - git status"
    echo "  dotsc <msg>   dotfiles commit - git add all + commit with message"
    echo "  dotsp         dotfiles push - git push"
  else
    cd ~/dotfiles
  fi
}
dotsc() {
  cd ~/dotfiles && git add . && git commit -m "$*"
}
alias dotss='git -C ~/dotfiles status'
alias dotsp='cd ~/dotfiles && git push'
export PATH="$HOME/.local/bin:$HOME/.gem/ruby/3.4.0/bin:$HOME/.gem/ruby/3.4.5/bin:$PATH"
alias lg='lazygit'

# LazyVPN
export PATH="$HOME/.local/share/lazyvpn/bin:$PATH"
