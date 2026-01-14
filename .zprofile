#!/usr/bin/env zsh

# Additional PATH entries
path=(
  $HOME/.local/bin
  $HOME/.cargo/bin
  $HOME/.opencode/bin
  $path
)

# eza configuration
eza_params=('--git' '--icons' '--classify' '--group-directories-first' '--time-style=long-iso' '--group' '--color-scale')
