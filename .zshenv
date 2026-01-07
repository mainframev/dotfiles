#!/usr/bin/env zsh

# Dynamically detect dotfiles directory from this file's location
# This works both locally and in CI where the repo path may differ
if [ -L "${(%):-%x}" ]; then
    # If .zshenv is a symlink (stow), get the real path and navigate to dotfiles root
    local real_path="$(readlink "${(%):-%x}")"
    DOTFILES="$(cd "$(dirname "$real_path")/.." && pwd)"
else
    # Fallback to default location
    DOTFILES="$HOME/dotfiles"
fi

# Path to your oh-my-zsh installation.
ZSH="$HOME/.oh-my-zsh"
TIMING=0
EDITOR="nvim"
VISUAL="nvim"
NVM_DIR="$HOME/.nvm"
DOTFILES_ZSH="$DOTFILES/.config/zsh"
STARSHIP_CONFIG="$DOTFILES/.config/starship.toml"
SNACKS_GHOSTTY=true

# DISABLE_AUTO_UPDATE="true"
DISABLE_MAGIC_FUNCTIONS="true"
DISABLE_COMPFIX="true"

ZSH_DISABLE_COMPFIX=true
GIT_AUTO_FETCH_INTERVAL=4140
GIT_PROMPT_EXECUTABLE="haskell"
POWERLEVEL9K_INSTANT_PROMPT=quiet
