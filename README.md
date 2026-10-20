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

## Agent instructions

- `AGENTS.md` contains instructions for working in this dotfiles repository.
- `common/AGENTS.md` contains cross-project rules. dotstate links it to
  `$HOME/AGENTS.md`.
- Repository-local instruction files can refine or override the user-level
  defaults. Tools with different discovery behavior may require their own
  supported instruction entry point.
- Medium-or-larger features use Worktrunk worktrees under
  `$HOME/worktrees/<repository>/<sanitized-branch>`. The user chooses whether
  formal SDD uses OpenSpec or no formal framework.

## Agent skills

- `common/.agents/skills/` holds skills shared by every coding agent. dotstate
  links each one into `$HOME/.agents/skills/`, the same directory the
  [skills CLI](https://github.com/vercel-labs/skills) installs into, so that
  directory stays real instead of becoming a link into the repo.
- Harness directories point at the shared copy: `common/.config/opencode/skills/`
  carries a tracked symlink, and `~/.claude/skills/`, `~/.codex/skills/` and
  `~/.copilot/skills/` get one via
  `ln -s ../../.agents/skills/<name> ~/<harness>/skills/<name>`.
- `paranoid-review` is an adversarial, evidence-first code review that reports
  only verified defects and lists unproven concerns separately.

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
everything with dotstate. Files in the way are moved to
`~/.dotstate-backups/<timestamp>/` with their paths kept. Re-running is safe and
links paths added to the manifest since. Run `./test.sh` to validate configs and
installer behavior.

## Local, untracked files

The repository is public. Keep credentials and machine-specific settings out of it:

- `~/.gitconfig.local`: credential helpers, work tenants and `scalar`/`maintenance`
  repos. `.gitconfig` includes it last, so it overrides tracked settings. Use
  `git config --file ~/.gitconfig.local ...` instead of `git config --global`,
  which writes through the symlink into this repository.
- `common/.config/zsh/secrets.zsh`: secret `export`s. Gitignored, sourced from `.zshrc`
  when present. Create it with mode `600`.
- `~/.copilot/`: Copilot CLI settings and state are not tracked or linked.
  `~/.copilot` must be a real directory, not a link into this repository.

What I currently use:

- [Aerospace](https://nikitabobko.github.io/AeroSpace/guide) - Tiling window manager for macOS
- [Bat](https://github.com/sharkdp/bat) - Cat clone with syntax highlighting
- [btop](https://github.com/aristocratos/btop) - Resource monitor
- [ccstatusline](https://github.com/sirmalloc/ccstatusline) - Claude Code status line
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
- [Starship](https://starship.rs/) - Cross-shell prompt
- [Taskwarrior](https://taskwarrior.org/) - Command line task manager
- [Tmux](https://github.com/tmux/tmux/wiki) - Terminal multiplexer
- [Worktrunk](https://worktrunk.dev/) - Git worktree manager (`wt`)
- [Yazi](https://github.com/sxyazi/yazi) - Blazing fast terminal file manager
- [Zed](https://zed.dev/) - Code editor
- [Zsh](https://www.zsh.org/) with [Oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh) - Shell with framework
