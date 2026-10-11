#!/bin/env zsh

# FZF Configuration


export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always {} | head -n 50'"
export FZF_COMPLETION_DIR_COMMANDS="cd pushd rmdir tree ls"


export FZF_DEFAULT_OPTS="
  --highlight-line
	--color=fg:#908caa,bg:#232136,hl:#ea9a97
	--color=fg+:#e0def4,bg+:#393552,hl+:#ea9a97
	--color=border:#44415a,header:#3e8fb0,gutter:#232136
	--color=spinner:#f6c177,info:#9ccfd8
	--color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa
  --preview-window=border-sharp --padding=1
"

# Aliases do not apply inside fzf previews, so call eza directly.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd|tree)      fzf --preview 'eza --tree --level=2 --color=always {} | head -n 200' "$@" ;;
    *)            fzf "$@" ;;
  esac
}

_fzf_compgen_path() {
    rg --files --glob "!.git" "$1"
}

_fzf_compgen_dir() {
   fd --type d --hidden --follow --exclude ".git" "$1"
}

# Enable fzf keybindings. zsh-vi-mode resets keymaps on init, so bind after it.
if (( ${+functions[zvm_init]} )); then
  zvm_after_init_commands+=('source <(fzf --zsh)')
else
  source <(fzf --zsh)
fi


