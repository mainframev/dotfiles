#!/bin/env zsh

# own aliases
alias vi="nvim"
alias cl="clear"
alias y="yarn"
alias ggf='gpf'
alias gdc='git diff --cached'

alias ls='eza $eza_params'
alias l='eza --git-ignore $eza_params'
alias ll='eza --all --header --long $eza_params'
alias llm='eza --all --header --long --sort=modified $eza_params'
alias la='eza -lbhHigUmuSa'
alias lx='eza -lbhHigUmuSa@'
alias lt='eza --tree $eza_params'
alias tree='eza --tree $eza_params'
alias pip='/usr/bin/pip3'
