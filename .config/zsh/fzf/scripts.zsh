#!/usr/bin/env zsh

# Find in File using ripgrep
fif() {
  if [ ! "$#" -gt 0 ]; then return 1; fi
  rg --files-with-matches --no-messages "$1" \
      | fzf --preview "highlight -O ansi -l {} 2> /dev/null \
      | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' \
      || rg --ignore-case --pretty --context 10 '$1' {}"
}

# Find in file using ripgrep-all
fifa() {
    if [ ! "$#" -gt 0 ]; then return 1; fi
    local file
    file="$(rga --max-count=1 --ignore-case --files-with-matches --no-messages "$*" \
        | fzf-tmux -p +m --preview="rga --ignore-case --pretty --context 10 '"$*"' {}")" \
        && print -z "./$file" || return 1;
}

# fzf and zoxide QOL functions
zz() {
  local dir
  dir=$(zoxide query -l | fzf) && z "$dir"
}

# with tree preview
zfp() {
  local dir
  dir=$(zoxide query -l | fzf --preview 'tree -CL 2 {}')
  [ -n "$dir" ] && z "$dir" && ls -la
 }

# recent dirs
zr() {
  local dir
  dir=$(zoxide query -l | sort -k2 -rn | fzf)
  [ -n "$dir" ] && z "$dir"
 }

fd() {
  preview="git diff $@ --color=always -- {-1}"
  git diff $@ --name-only | fzf -m --ansi --preview $preview
}


