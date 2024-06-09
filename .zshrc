# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

path+=/usr/local/bin/ghc
path+=$HOME/.cargo/bin

eval "$(/opt/homebrew/bin/brew shellenv)"

export PATH;

source <(fzf --zsh)

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export TIMING=0
export NVM_DIR=~/.nvm
export FZF_BASE="/opt/homebrew/opt/fzf"
export EDITOR="nvim"
export NVM_DIR="$HOME/.nvm"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"
ZSH_DISABLE_COMPFIX=true
GIT_AUTO_FETCH_INTERVAL=4140
GIT_PROMPT_EXECUTABLE="haskell"


plugins=(
  git
  gitignore
  git-auto-fetch
  git-prompt
  last-working-dir
  history
  vscode
  npm
  nvm
  sudo
  themes
  encode64
  jira
  zsh-autosuggestions
  zsh-syntax-highlighting
  Stack
  tmux
  tmuxinator
  z
  zsh-eza
)

source $ZSH/oh-my-zsh.sh

eza_params=('--git' '--icons' '--classify' '--group-directories-first' '--time-style=long-iso' '--group' '--color-scale')

# own aliases 
alias vi="nvim"
alias cl="clear"
alias y="yarn"
alias ggf='gpf'

alias ls='eza $eza_params'
alias l='eza --git-ignore $eza_params'
alias ll='eza --all --header --long $eza_params'
alias llm='eza --all --header --long --sort=modified $eza_params'
alias la='eza -lbhHigUmuSa'
alias lx='eza -lbhHigUmuSa@'
alias lt='eza --tree $eza_params'
alias tree='eza --tree $eza_params'


[ -f "/Users/rejuv/.ghcup/env" ] && source "/Users/rejuv/.ghcup/env" # ghcup-env

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
if command -v zoxide > /dev/null; then
  eval "$(zoxide init zsh)"
fi

# yazi-cwd
function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
