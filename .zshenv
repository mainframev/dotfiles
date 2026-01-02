#!/bin/env zsh

# PATH
path+=/usr/local/bin/ghc
path+=$HOME/.cargo/bin
path+=$HOME/.opencode/bin

eval "$(/opt/homebrew/bin/brew shellenv)"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export TIMING=0
export EDITOR="nvim"
export VISUAL="nvim"
export NVM_DIR="$HOME/.nvm"
export DOTFILES="$HOME/dotfiles"
export DOTFILES_ZSH="$HOME/dotfiles/.config/zsh"
export STARSHIP_CONFIG="$DOTFILES/.config/starship/config.toml"
export SNACKS_GHOSTTY=true

# ZSH_THEME="powerlevel10k/powerlevel10k"
ZSH_DISABLE_COMPFIX=true
GIT_AUTO_FETCH_INTERVAL=4140
GIT_PROMPT_EXECUTABLE="haskell"
OWERLEVEL9K_INSTANT_PROMPT=quiet

eza_params=('--git' '--icons' '--classify' '--group-directories-first' '--time-style=long-iso' '--group' '--color-scale')


