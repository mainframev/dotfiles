#!/bin/env zsh

# | YAZI |
source $DOTFILES_ZSH/yazi.zsh

# | OH-MY_ZSH |
source $DOTFILES_ZSH/oh-my-zsh.zsh

# | FZF |
if [ $(command -v "fzf") ]; then
  source $DOTFILES_ZSH/fzf.zsh
fi

# | BREW |
if [ $(command -v "brew") ]; then
  source $DOTFILES_ZSH/brew.zsh
fi

# | ALIASES |
source $DOTFILES_ZSH/aliases.zsh

# | STARSHIP |
eval "$(starship init zsh)"


export PATH="/Users/rejuv/dotfiles/git-fuzzy/bin:$PATH"
