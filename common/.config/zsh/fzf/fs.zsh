#!/usr/bin/env zsh

_find_file() {
  local file
  file=$(fzf --preview="bat --color=always {}" --preview-window=up:50%:border-horizontal) || return
  nvim "$file"
}

function register_fzf_fs() {
  alias ff=_find_file
}


register_fzf_fs
