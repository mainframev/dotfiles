#!/usr/bin/env zsh

# PATH configuration - prepend to ensure priority
path=(/opt/homebrew/bin $path)
path=(/usr/local/bin $path)
path=(/usr/local/bin/ghc $path)
path+=($HOME/.cargo/bin)
path+=($HOME/.opencode/bin)

eval "$(/opt/homebrew/bin/brew shellenv)"

# eza configuration
eza_params=('--git' '--icons' '--classify' '--group-directories-first' '--time-style=long-iso' '--group' '--color-scale')
