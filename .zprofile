#!/usr/bin/env zsh

if [ -n "$HOMEBREW_PREFIX" ] && [ -x "$HOMEBREW_PREFIX/bin/brew" ]; then
  eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"
fi

path=(
  /usr/local/sbin
  /usr/sbin
  /sbin
  $path
)

# eza configuration
eza_params=('--git' '--icons' '--classify' '--group-directories-first' '--time-style=long-iso' '--group' '--color-scale')
