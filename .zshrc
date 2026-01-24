#!/bin/env zsh

# enable zsh profiling
# zmodload zsh/zprof

# Do not rebuild completion dump file every time, only once a day
autoload -Uz compinit

# Cross-platform stat command for checking file modification date
if [ -n "$IS_MACOS" ]; then
    # macOS uses BSD stat
    zcompdump_date="$(stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)"
else
    # Linux uses GNU stat - convert timestamp to day of year
    if [ -f ~/.zcompdump ]; then
        zcompdump_date="$(date -d @$(stat -c '%Y' ~/.zcompdump 2>/dev/null) +'%j' 2>/dev/null)"
    else
        zcompdump_date=""
    fi
fi

if [ "$(date +'%j')" != "$zcompdump_date" ]; then
    compinit
else
    compinit -C
fi
unset zcompdump_date

# | SCRIPTS |
source $DOTFILES_ZSH/scripts.zsh

# | YAZI |
source $DOTFILES_ZSH/yazi.zsh

# | OH-MY_ZSH |
source $DOTFILES_ZSH/oh-my-zsh.zsh

# | FZF |
if [ $(command -v "fzf") ]; then
  for file in $DOTFILES_ZSH/fzf/*.zsh; do
    source "$file"
  done
fi

# | ALIASES |
source $DOTFILES_ZSH/aliases.zsh

# | SECRETS |
if [[ -f "$DOTFILES_ZSH/secrets.zsh" ]]; then
  source "$DOTFILES_ZSH/secrets.zsh"
fi

# | STARSHIP |
if [ $(command -v "starship") ]; then
  eval "$(starship init zsh)"
fi

# End profiling
# zprof
export PATH="$HOME/.local/bin:$PATH"
