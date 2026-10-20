#!/usr/bin/env zsh

if [ -n "$HOMEBREW_PREFIX" ] && [ -x "$HOMEBREW_PREFIX/bin/brew" ]; then
  eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"
fi

# Login PATH order. On macOS /etc/zprofile (path_helper) runs after .zshenv and
# pushes user dirs behind system ones, so set the final order here.
# typeset -U path (in .zshenv) keeps the first occurrence of each entry.
# /usr/local/bin precedes Homebrew so Microsoft Git and Scalar win over brew git.
path=(
  $HOME/.local/bin
  $HOME/.cargo/bin
  /usr/local/bin
  ${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/bin}
  ${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/sbin}
  $path
  $HOME/.docker/bin
)

# eza configuration
eza_params=('--git' '--icons' '--classify' '--group-directories-first' '--time-style=long-iso' '--group' '--color-scale')
