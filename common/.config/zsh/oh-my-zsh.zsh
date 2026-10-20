#!/usr/bin/env zsh

# nvm/z/themes are not loaded: fnm and zoxide replace them and starship is the prompt.
plugins=(
  git
  git-auto-fetch
  sudo
  encode64
  gh
  zsh-eza
  zsh-interactive-cd
)

# Custom plugins cloned by install.sh (install_zsh_plugins). Keep both lists in sync;
# test.sh checks it. Missing plugins are skipped instead of cloned at startup.
github_plugins=(
  zsh-users/zsh-autosuggestions
  zsh-users/zsh-syntax-highlighting
  z-shell/zsh-eza
  jeffreytse/zsh-vi-mode
)

# Keep the completion dump out of $HOME.
ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${HOST%%.*}-$ZSH_VERSION"
[[ -d ${ZSH_COMPDUMP:h} ]] || mkdir -p ${ZSH_COMPDUMP:h}

# Load oh-my-zsh FIRST (it runs compinit internally)
source $ZSH/oh-my-zsh.sh

# Load custom github plugins AFTER oh-my-zsh
for plugin in $github_plugins; do
  plugin_name=${plugin#*/}
  for initscript in ${plugin_name}.zsh ${plugin_name}.plugin.zsh ${plugin_name}.sh; do
    if [[ -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/$plugin_name/$initscript ]]; then
      source ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/$plugin_name/$initscript
      break
    fi
  done
done

unset github_plugins
unset plugin
unset initscript
