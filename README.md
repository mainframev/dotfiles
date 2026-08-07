My dotfiles managed with [STOW](https://www.gnu.org/software/stow/)

## Agent instructions

- `AGENTS.md` contains instructions for working in this dotfiles repository.
- `GLOBAL_AGENTS.md` contains cross-project rules. During setup, `install.sh`
  links it to `$HOME/AGENTS.md`.
- Repository-local instruction files can refine or override the user-level
  defaults. Tools with different discovery behavior may require their own
  supported instruction entry point.
- Medium-or-larger features use Worktrunk worktrees under
  `$HOME/worktrees/<repository>/<sanitized-branch>`. The user chooses whether
  formal SDD uses OpenSpec, Superpowers, both, or neither.

What I currently use:

- [Aerospace](https://nikitabobko.github.io/AeroSpace/guide) - Tiling window manager for macOS
- [Alacritty](https://alacritty.org/) - GPU-accelerated terminal emulator
- [Bat](https://github.com/sharkdp/bat) - Cat clone with syntax highlighting
- [Git](https://git-scm.com/) with [Delta](https://github.com/dandavison/delta) - Version control with Delta configured as the pager
- [GitHub CLI](https://cli.github.com/) - GitHub command line tool
- [gh-dash](https://github.com/dlvhdr/gh-dash) - GitHub CLI dashboard
- [Ghostty](https://ghostty.org/) - Terminal emulator
- [Kitty](https://sw.kovidgoyal.net/kitty/) - Fast, feature-rich terminal emulator
- [Neovim](https://neovim.io/) - Hyperextensible Vim-based text editor
- [OpenCode](https://opencode.ai/) - AI coding assistant
- [Starship](https://starship.rs/) - Cross-shell prompt
- [Tmux](https://github.com/tmux/tmux/wiki) - Terminal multiplexer
- [Yazi](https://github.com/sxyazi/yazi) - Blazing fast terminal file manager
- [Zsh](https://www.zsh.org/) with [Oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh) - Shell with framework
