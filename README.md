My dotfiles managed with [STOW](https://www.gnu.org/software/stow/)

## Global agent defaults

Stow links the repository's `AGENTS.md` to `$HOME/AGENTS.md`. Coding agents
that discover `AGENTS.md` files in ancestor directories can use it as global
defaults. The repository file is a template to customize. Tools with different
discovery behavior may require their own entry point. A repository-local
`AGENTS.md` should refine or override these global defaults for that project.

What I currently use:

- [Aerospace](https://nikitabobko.github.io/AeroSpace/guide) - Tiling window manager for macOS
- [Alacritty](https://alacritty.org/) - GPU-accelerated terminal emulator
- [Bat](https://github.com/sharkdp/bat) - Cat clone with syntax highlighting
- [Git](https://git-scm.com/) with [Delta](https://github.com/dandavison/delta) - Version control with enhanced diff viewer
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
