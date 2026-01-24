#!/bin/env zsh

# own aliases

alias ai='opencode'
alias cl="clear -x"
alias gdc='git diff --cached'
alias ggf='gpf'
alias ghd="gh dash"
alias ghp="gh pr"
alias ghs="gh status"
alias l='eza --git-ignore $eza_params'
alias la='eza -lbhHigUmuSa'
alias ll='eza --all --header --long $eza_params'
alias llm='eza --all --header --long --sort=modified $eza_params'
alias ls='eza $eza_params'
alias lt='eza --tree $eza_params'
alias lx='eza -lbhHigUmuSa@'
alias pip='/usr/bin/pip3'
alias plugpull="find ${ZDOTDIR:-$HOME}/.zsh_plugins -type d -exec test -e '{}/.git' ';' -print0 | xargs -I {} -0 git -C {} pull"
alias src='source ~/.zshrc && echo "Reloaded .zshrc"'
alias tasks='taskwarrior-tui'
alias tree='eza --tree $eza_params'
alias tskbdd='task burndown.daily'
alias tskbdm='task burndown.monthly'
alias tskbdw='task burndown.weekly'
alias tskcal='task calendar'
alias tskhsd='task history.daily'
alias tskhsm='task history.monthly'
alias tskhsw='task history.weekly'
alias tskhsy='task history.annual'
alias tskl='task list'
alias tskp='task projects'
alias tskrp='task reports'
alias tskrpd='task ghistory.daily'
alias tskrpm='task ghistory.monthly'
alias tskrpw='task ghistory.weekly'
alias tskrpy='task ghistory.annual'
alias tsksm='task summary'
alias tskst='task stats'
alias tskts='task timesheet'
alias vi="nvim"
alias y="yarn"
alias faliases='alias | fzf --prompt="alias> " \
  --preview '\''echo {} | sed "s/^[^=]*=//" | sed "s/^'\'''\''//; s/'\'''\''$//" | bat --language=bash --style=plain --color=always'\'''
