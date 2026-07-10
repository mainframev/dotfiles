#!/bin/env zsh

# own aliases
alias ai='opencode'
alias cl="clear -x"
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
alias mail="neomutt"
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
alias vi='nvim'
alias wtl='wt list'
alias wtm='wt merge'
alias wtr='wt remove'
alias wts='wt switch'
alias y='yarn'

memtop() {
  local width=${COLUMNS:-$(tput cols 2>/dev/null || echo 120)}
  local cmd_max=$((width - 22))
  (( cmd_max < 40 )) && cmd_max=40
  {
    printf 'PID\tMEM\tCOMMAND\n'
    ps -axo pid,rss,command | sort -k2 -nr | head -20 | awk -v max="$cmd_max" '{
      pid=$1; rss=$2; $1=$2=""; sub(/^  /,"")
      if (rss >= 1048576)      mem=sprintf("%.1f GB", rss/1048576)
      else if (rss >= 1024)    mem=sprintf("%.0f MB", rss/1024)
      else                     mem=sprintf("%d KB", rss)
      if (length($0) > max) $0 = substr($0, 1, max-1) "\xe2\x80\xa6"
      printf "%s\t%s\t%s\n", pid, mem, $0
    }'
  } | column -t -s $'\t'
}

memsusp() {
  local width=${COLUMNS:-$(tput cols 2>/dev/null || echo 120)}
  local cmd_max=$((width - 28))
  (( cmd_max < 40 )) && cmd_max=40
  {
    printf 'PID\tSTAT\tELAPSED\tCOMMAND\n'
    ps -axo pid,stat,etime,command | awk -v max="$cmd_max" '$2 ~ /T/ && $1 != "PID" {
      pid=$1; stat=$2; etime=$3; $1=$2=$3=""; sub(/^   /,"")
      if (length($0) > max) $0 = substr($0, 1, max-1) "\xe2\x80\xa6"
      printf "%s\t%s\t%s\t%s\n", pid, stat, etime, $0
    }'
  } | column -t -s $'\t'
}
