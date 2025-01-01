#!/bin/env zsh

# PATH
path+=/usr/local/bin/ghc
path+=$HOME/.cargo/bin

eval "$(/opt/homebrew/bin/brew shellenv)"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export TIMING=0
export EDITOR="nvim"
export VISUAL="nvim"
export NVM_DIR="$HOME/.nvm"
export DOTFILES="$HOME/dotfiles"
export DOTFILES_ZSH="$HOME/dotfiles/.config/zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"
ZSH_DISABLE_COMPFIX=true
GIT_AUTO_FETCH_INTERVAL=4140
GIT_PROMPT_EXECUTABLE="haskell"
OWERLEVEL9K_INSTANT_PROMPT=quiet

eza_params=('--git' '--icons' '--classify' '--group-directories-first' '--time-style=long-iso' '--group' '--color-scale')

# FZF
FZF_COLORS="bg+:-1,\
fg:gray,\
fg+:white,\
border:black,\
spinner:0,\
hl:yellow,\
header:blue,\
info:green,\
pointer:red,\
marker:blue,\
prompt:gray,\
hl+:red"

export FZF_BASE="/opt/homebrew/opt/fzf"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--height 60% \
--border sharp \
--layout reverse \
--color '$FZF_COLORS' \
--prompt '∷ ' \
--pointer ▶ \
--marker ⇒"

export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -n 10'"
export FZF_COMPLETION_DIR_COMMANDS="cd pushd rmdir tree ls"
