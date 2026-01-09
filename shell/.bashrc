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
export PATH="$HOME/.gem/ruby/3.4.0/bin:$HOME/.gem/ruby/3.4.5/bin:$PATH"
