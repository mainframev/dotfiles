My dotfiles managed with [dotstate](https://github.com/serkanyersen/dotstate)

## Layout

dotstate links each path listed in `.dotstate-profiles.toml` from the
repository into `$HOME`:

- `common/`: configs shared by every machine.
- `macos/`: macOS-only configs (AeroSpace, Ghostty, Kitty, Zed), linked by the
  `macos` profile.
- `linux` profile: common configs only, used on Linux and in Codespaces.

Edit configs at their usual paths; the links write through to this repository.
Common tasks:

```sh
dotstate add ~/.config/foo --common --yes   # track a new config for every machine
dotstate profile switch macos               # pick this machine's profile
dotstate doctor                             # check links and the manifest
dotstate sync -m "Update foo"               # commit, pull --rebase and push
```

## Install

```sh
git clone git@github.com:mainframev/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh            # everything
./install.sh --no-gui   # CLI tools only, no casks
```

`install.sh` installs Homebrew and the Brewfile, oh-my-zsh and its custom
plugins, and dotstate (from its Homebrew tap on macOS, the pinned release on
Linux). On first run it writes `~/.config/dotstate/config.toml` for this
checkout in Local mode with the `macos` or `linux` profile, then links
everything with dotstate and reinstalls any agent skill recorded in
`~/.agents/.skill-lock.json` that is missing from `~/.agents/skills`, using
`npx skills add --global --agent claude-code`. Files in the way are moved to
`~/.dotstate-backups/<timestamp>/` with their paths kept. Re-running is safe and
links paths added to the manifest since. Run `./test.sh` to validate configs and
installer behavior.

Coming from the old Stow layout, `install.sh` moves untracked state left at the
old paths (for example `.config/zsh/secrets.zsh`, herdr sessions, tmux plugins)
into `common/` or `macos/`, and drops dangling folded Stow links such as
`~/.pi/agent`. To stop managing a path, run `dotstate remove <path> --yes`
before deleting it from the repository, or `dotstate doctor` keeps reporting its
dangling link.

What I currently use:

- [Aerospace](https://nikitabobko.github.io/AeroSpace/guide) - Tiling window manager for macOS
- [Bat](https://github.com/sharkdp/bat) - Cat clone with syntax highlighting
- [btop](https://github.com/aristocratos/btop) - Resource monitor
- [ccstatusline](https://github.com/sirmalloc/ccstatusline) - Claude Code status line
- [Claude Code](https://code.claude.com/) - AI coding agent; only `~/.claude/settings.json` (statusline, plugins, marketplaces, theme) and `~/.claude/themes` are managed. Keep project-specific `autoMode` and permissions out of the tracked file, since this repository is public
- [Git](https://git-scm.com/) with [Delta](https://github.com/dandavison/delta) - Version control with Delta configured as the pager
- [GitHub CLI](https://cli.github.com/) - GitHub command line tool
- [gh-dash](https://github.com/dlvhdr/gh-dash) - GitHub CLI dashboard
- [Ghostty](https://ghostty.org/) - Terminal emulator
- [herdr](https://herdr.dev) - Terminal agent multiplexer
- [Kitty](https://sw.kovidgoyal.net/kitty/) - Fast, feature-rich terminal emulator
- [lazygit](https://github.com/jesseduffield/lazygit) - Terminal UI for Git
- [Neovim](https://neovim.io/) - Hyperextensible Vim-based text editor
- [OpenCode](https://opencode.ai/) - AI coding assistant
- [pi](https://github.com/earendil-works/pi) - Coding agent; only `~/.pi/agent/settings.json` is managed, and pi installs missing packages from it on startup
- [skills](https://github.com/vercel-labs/skills) - Agent skills CLI; its lockfile `~/.agents/.skill-lock.json` is managed, the installed skills are not
- [Starship](https://starship.rs/) - Cross-shell prompt
- [Taskwarrior](https://taskwarrior.org/) - Command line task manager
- [Tmux](https://github.com/tmux/tmux/wiki) - Terminal multiplexer
- [Worktrunk](https://worktrunk.dev/) - Git worktree manager (`wt`)
- [Yazi](https://github.com/sxyazi/yazi) - Blazing fast terminal file manager
- [Zed](https://zed.dev/) - Code editor
- [Zsh](https://www.zsh.org/) with [Oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh) - Shell with framework
