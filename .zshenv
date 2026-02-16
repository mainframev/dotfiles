#!/usr/bin/env zsh

# Deduplicate PATH entries
typeset -U path

# Platform detection
case "$(uname -s)" in
  Darwin)
    export IS_MACOS=1
    # Detect Homebrew location (Apple Silicon vs Intel)
    if [ -d "/opt/homebrew" ]; then
      export HOMEBREW_PREFIX="/opt/homebrew"
    elif [ -d "/usr/local/Homebrew" ]; then
      export HOMEBREW_PREFIX="/usr/local"
    fi
    ;;
  Linux)
    export IS_LINUX=1
    # Check for Homebrew on Linux
    if [ -d "/home/linuxbrew/.linuxbrew" ]; then
      export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
    elif [ -d "$HOME/.linuxbrew" ]; then
      export HOMEBREW_PREFIX="$HOME/.linuxbrew"
    fi
    ;;
esac

path=(
  $HOME/.local/bin
  $HOME/.cargo/bin
  $HOME/.opencode/bin
  $path
)

# Dynamically detect dotfiles directory from this file's location
# This works both locally and in CI where the repo path may differ
if [ -L "${(%):-%x}" ]; then
    # If .zshenv is a symlink (stow), resolve to find dotfiles root
    # readlink gives us the target: dotfiles/.zshenv
    # We need to get the directory containing that file
    local real_path
    real_path="$(readlink "${(%):-%x}" 2>/dev/null)"
    if [ -n "$real_path" ]; then
        # Handle both absolute and relative symlinks
        if [[ "$real_path" = /* ]]; then
            # Absolute path: /full/path/to/dotfiles/.zshenv -> /full/path/to/dotfiles
            DOTFILES="${real_path:h}"
        else
            # Relative path: dotfiles/.zshenv -> resolve from $HOME
            DOTFILES="$HOME/${real_path:h}"
        fi
    else
        DOTFILES="$HOME/dotfiles"
    fi
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
export TASKRC="$DOTFILES/.config/task/taskrc"
export TASKDATA="$HOME/.local/share/task"
SNACKS_GHOSTTY=true

# DISABLE_AUTO_UPDATE="true"
DISABLE_MAGIC_FUNCTIONS="true"
DISABLE_COMPFIX="true"

ZSH_DISABLE_COMPFIX=true
GIT_AUTO_FETCH_INTERVAL=4140
GIT_PROMPT_EXECUTABLE="haskell"
POWERLEVEL9K_INSTANT_PROMPT=quiet
