#!/bin/env zsh

# | POWERSHELL10K (p10k) | 
# should be source at the top
source $DOTFILES_ZSH/p10k.zsh

# | YAZI |
source $DOTFILES_ZSH/yazi.zsh

# | OH-MY_ZSH |
source $DOTFILES_ZSH/oh-my-zsh.zsh

# | FZF |
if [ $(command -v "fzf") ]; then
  source $DOTFILES_ZSH/fzf.zsh
fi

# | ALIASES |
source $DOTFILES_ZSH/aliases.zsh
