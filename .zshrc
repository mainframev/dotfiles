#!/bin/env zsh

# enable zsh profiling
# zmodload zsh/zprof

# compinit runs inside oh-my-zsh (see .config/zsh/oh-my-zsh.zsh)

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

if command -v fnm >/dev/null 2>&1; then eval "$(fnm env --use-on-cd --shell zsh)"; fi

if command -v zoxide >/dev/null 2>&1; then eval "$(zoxide init zsh)"; fi

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi

# BEGIN Agency MANAGED BLOCK
if [[ ":${PATH}:" != *":/Users/mainframev/.config/agency/CurrentVersion:"* ]]; then
    export PATH="/Users/mainframev/.config/agency/CurrentVersion:${PATH}"
fi
# END Agency MANAGED BLOCK

# Non-login shells (launchd minimal PATH) still need /usr/local/bin for
# Microsoft Git and Scalar; login shells get it from .zprofile.
(( ${path[(Ie)/usr/local/bin]} )) || path=(/usr/local/bin $path)

# pnpm
if [[ -n $IS_MACOS ]]; then
  export PNPM_HOME="$HOME/Library/pnpm"
else
  export PNPM_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/pnpm"
fi
path=($PNPM_HOME/bin $path)
# pnpm end

