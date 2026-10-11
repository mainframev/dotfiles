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

# | STARSHIP |
if [ $(command -v "starship") ]; then
  eval "$(starship init zsh)"
fi

# End profiling
# zprof

# | SECRETS | untracked, machine-local exports (see README)
[[ -r $DOTFILES_ZSH/secrets.zsh ]] && source $DOTFILES_ZSH/secrets.zsh

eval "$(fnm env --use-on-cd --shell zsh)"

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi

# Prefer Microsoft Git and its Scalar client over Homebrew Git.
path=(/usr/local/bin $path)

# BEGIN Agency MANAGED BLOCK
if [[ ":${PATH}:" != *":/Users/mainframev/.config/agency/CurrentVersion:"* ]]; then
    export PATH="/Users/mainframev/.config/agency/CurrentVersion:${PATH}"
fi
# END Agency MANAGED BLOCK

# pnpm
export PNPM_HOME="/Users/mainframev/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

