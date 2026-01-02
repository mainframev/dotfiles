#!/bin/env zsh

# own aliases
alias vi="nvim"
alias cl="clear -x"
alias y="yarn"
alias ggf='gpf'
alias gdc='git diff --cached'
alias ai='opencode'
alias src='source ~/.zshrc && echo "Reloaded .zshrc"'

alias l='eza --git-ignore $eza_params'
alias la='eza -lbhHigUmuSa'
alias ll='eza --all --header --long $eza_params'
alias llm='eza --all --header --long --sort=modified $eza_params'
alias ls='eza $eza_params'
alias lt='eza --tree $eza_params'
alias lx='eza -lbhHigUmuSa@'
alias pip='/usr/bin/pip3'
alias tree='eza --tree $eza_params'
