
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
  zsh-autosuggestions
  zsh-syntax-highlighting
)

github_plugins=(
  wfxr/forgit
)

# for plugin in $github_plugins; do
#   plugin_name=${plugin#*/}
#   # clone the plugin from github if it doesn't exist
#   if [[ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/$plugin_name ]]; then
#     mkdir -p ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins
#     git clone --depth 1 --recursive https://github.com/$plugin.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/$plugin_name
#   fi
#   # load the plugin
#   for initscript in ${plugin_name}.zsh ${plugin_name}.plugin.zsh ${plugin_name}.sh; do
#     if [[ -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/$plugin_name/$initscript ]]; then
#       source ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/$plugin_name/$initscript
#       break
#     fi
#   done
# done
#
source $ZSH/oh-my-zsh.sh
#
# unset github_plugins
# unset plugin
# unset initscript
#
