#!/bin/env zsh

# enable zsh profiling
# zmodload zsh/zprof

# Do not rebuild completion dump file every time, only once a day
autoload -Uz compinit
if [ "$(date +'%j')" != "$(stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)" ]; then
    compinit
else
    compinit -C
fi

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

# End profiling
# zprof
