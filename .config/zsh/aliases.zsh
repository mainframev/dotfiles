#!/bin/env zsh

# own aliases
alias vi="nvim"
alias cl="clear -x"
alias y="yarn"
alias ggf='gpf'
alias ghd="gh dash"
alias ghs="gh status"
alias ghp="gh pr"
alias gdc='git diff --cached'
alias ai='opencode'
alias src='source ~/.zshrc && echo "Reloaded .zshrc"'
alias tasks='taskwarrior-tui'
alias plugpull="find ${ZDOTDIR:-$HOME}/.zsh_plugins -type d -exec test -e '{}/.git' ';' -print0 | xargs -I {} -0 git -C {} pull"

alias l='eza --git-ignore $eza_params'
alias la='eza -lbhHigUmuSa'
alias ll='eza --all --header --long $eza_params'
alias llm='eza --all --header --long --sort=modified $eza_params'
alias ls='eza $eza_params'
alias lt='eza --tree $eza_params'
alias lx='eza -lbhHigUmuSa@'
alias pip='/usr/bin/pip3'
alias tree='eza --tree $eza_params'
