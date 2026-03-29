#!/usr/bin/env zsh

function is_remote() {
	[ ! "$(git ls-remote --heads origin 2>/dev/null | wc -l | tr -s ' ')" -eq 0 ]
}

function is_git_repo() {
	[ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" = "true" ]
}

function _fzf_git_add() {
	if ! is_git_repo; then {
		echo "not a git repo"
		exit
	}; fi

	unstaged_list="$(git ls-files . --exclude-standard --others -m)"

	if [[ -n "$unstaged_list" ]]; then
		lines="$(
			echo "$unstaged_list" |
				fzf -d' ' \
					--exit-0 \
					--ansi --delimiter=: \
					--multi \
					--ghost="add files:" \
					--bind="focus:transform-footer:GH_FORCE_TTY=$FZF_PREVIEW_COLUMNS git diff --stat --color=always -- {1} __NOVAR__" \
					--expect="enter,ctrl-d" \
          --header=$'Enter: add file(s), Tab: select file(s), Ctrl-d: diff file(s)\n\n' \
					--no-info

		)"

		key="$(head -1 <<<"$lines")"
		files="$(sed 1d <<<"$lines")"

		case "$key" in
		enter) echo "$files" | xargs -n1 -t git add ;;
		ctrl-d) echo "$files" | xargs -n1 git diff ;;
		esac

	else
		echo "no files to stage"
		exit
	fi
}

function _fzf_git_prs() {
	if ! is_remote; then {
		echo "no gh remote found"
		exit
	}; fi

	open_prs="$(gh pr list "$@" -s"open")"

	if [[ -n "$open_prs" ]]; then

		lines="$(
			echo "$open_prs" | awk -F'\t' -v ID_COLOUR="$ID_COLOUR" -v TEXT_COLOUR="$TEXT_COLOUR" -v SHELL_COLOUR="$SHELL_COLOUR" \
				'{print ID_COLOUR $1 SHELL_COLOUR": " TEXT_COLOUR $2}' |
				fzf -d' ' \
					--exit-0 \
					--ansi --delimiter=: \
					--ghost="select PR" \
					--preview='GH_FORCE_TTY=$FZF_PREVIEW_COLUMNS gh pr view {1}' \
					--expect="enter,ctrl-d,ctrl-v" \
					--header=$'Enter: checkout PR, Ctrl-d: diff PR, Ctrl-v: view PR\n\n' \
					--no-info

		)"

		key="$(head -1 <<<"$lines")"
		id="$(sed 1d <<<"$lines" | cut -d: -f1)"

		case "$key" in
		enter) gh pr checkout "$id" ;;
		ctrl-d) gh pr diff "$id" ;;
		ctrl-v) gh pr view "$id" ;;
		esac

	else
		echo "no open PRs"
		exit
	fi
}

function _fzf_git_branches() {
	if ! is_git_repo; then {
		echo "not a git repo"
		exit
	}; fi

	lines="$(
		git branch -a --sort=-committerdate | sed 's/[* ]//g' | grep -v 'HEAD' |
			fzf -d' ' \
				--ghost="select branch" \
				--preview="git log --oneline --format='%C(bold blue)%h%C(reset) - %C(green)%ar%C(reset) - %C(cyan)%an%C(reset)%C(bold yellow)%d%C(reset): %s' --color=always {}" \
				--expect "enter,ctrl-d,ctrl-s,ctrl-x" \
				--header=$'Enter: checkout, Ctrl-d: diff branch, Ctrl-s: triple dot diff, Ctrl-x: delete branch\n\n' \
				--no-info
	)"

	key="$(head -1 <<<"$lines")"
	branch="$(sed '1d;s/remotes\///g' <<<"$lines")"

	case "$key" in
	enter) if [[ $branch == *"origin"* ]]; then git checkout --track "$branch"; else git checkout "$branch"; fi ;;
	ctrl-d) echo "$branch <-> $(git branch --show-current)" && git diff "$branch" ;;
	ctrl-s) echo "$branch <-> $(git branch --show-current)" && git diff "$branch"...HEAD ;;
	ctrl-x)
		read -rp "Delete branch \"$branch\"? [y|n] "
		if [[ $REPLY =~ ^[Yy]$ ]]; then git branch -D "$branch"; fi
		;;
	esac
}

function _fzf_git_diffs() {
	if ! is_git_repo; then {
		echo "not a git repo"
		exit
	}; fi

	lines="$(
		git diff --name-only | awk -F'.' '{print $NF}' | sort -u |
			fzf -d' ' \
				--no-multi \
				--exit-0 \
				--ghost="select extension:" \
				--preview="GH_FORCE_TTY=$FZF_PREVIEW_COLUMNS git diff --stat --color=always -- '*.{1}'" \
				--expect="enter,ctrl-d,ctrl-x" \
				--header=$'Enter: add file(s), Ctrl-d: diff file(s), Ctrl-x: checkout file(s)\n\n' \
				--no-info
	)"

	key="$(head -1 <<<"$lines")"
	extension="$(sed 1d <<<"$lines" | cut -d: -f2 | tr -d ' ')"

	case "$key" in
	enter) git diff --name-only | grep ".*\.$extension" | xargs -n 1 -t git add ;;
	ctrl-d) git diff -- "*.$extension" ;;
	ctrl-x) git diff --name-only | grep ".*\.$extension" | xargs -n 1 -t git checkout ;;
	esac
}

function _fzf_git_reset() {
	if ! is_git_repo; then {
		echo "not a git repo"
		exit
	}; fi

	staged_list="$(git diff --name-only --cached)"

	if [[ -n "$staged_list" ]]; then
		lines="$(
			echo "$staged_list" |
				fzf -d' ' \
					--exit-0 \
					--ansi --delimiter=: \
					--multi \
					--ghost="reset files:" \
					--bind="focus:transform-footer:GH_FORCE_TTY=$FZF_PREVIEW_COLUMNS git diff --cached --stat --color=always -- {1} __NOVAR__" \
					--expect="enter,ctrl-d" \
					--header=$'Enter: unstage file(s), Tab: select file(s), Ctrl-d: diff file(s)\n\n' \
					--no-info
		)"

		key="$(head -1 <<<"$lines")"
		files="$(sed 1d <<<"$lines")"

		case "$key" in
		enter) echo "$files" | xargs -n1 -t git restore --staged ;;
		ctrl-d) echo "$files" | xargs -n1 git diff --cached ;;
		esac

	else
		echo "no staged files"
		exit
	fi
}

function register_fzf_git() {
  alias gd=_fzf_git_diffs
  alias fgb=_fzf_git_branches
  alias fpr=_fzf_git_prs
  alias fga=_fzf_git_add
  alias fgr=_fzf_git_reset
}


register_fzf_git
