#!/bin/env zsh

alias fa='alias | fzf --prompt="alias> " \
  --preview '\''echo {} | sed "s/^[^=]*=//" | sed "s/^'\'''\''//; s/'\'''\''$//" | bat --language=bash --style=plain --color=always'\'''

alias ff='nvim $(fzf --preview="bat --color=always {}")'
