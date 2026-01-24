
#!/bin/env zsh

# Disable auto-update checks
zstyle ':omz:plugins:nvm' lazy yes

plugins=(
  git
  git-auto-fetch
  last-working-dir
  nvm
  sudo
  themes
  encode64
  gh
  z
  zsh-eza
  zsh-interactive-cd
)

# Auto-install custom plugins from GitHub if not present
# This runs on shell startup and ensures all plugins are available
github_plugins=(
  zsh-users/zsh-autosuggestions
  zsh-users/zsh-syntax-highlighting
  z-shell/zsh-eza
)

for plugin in $github_plugins; do
  plugin_name=${plugin#*/}
  # clone the plugin from github if it doesn't exist
  if [[ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/$plugin_name ]]; then
    mkdir -p ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins
    git clone --depth 1 --recursive https://github.com/$plugin.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/$plugin_name
  fi
done

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
