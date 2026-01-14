#!/usr/bin/env zsh

eval "$(/opt/homebrew/bin/brew shellenv)"

path=(
  $HOME/.local/bin
  $HOME/.cargo/bin
  $HOME/.opencode/bin
  $path
)

# eza configuration
eza_params=('--git' '--icons' '--classify' '--group-directories-first' '--time-style=long-iso' '--group' '--color-scale')
