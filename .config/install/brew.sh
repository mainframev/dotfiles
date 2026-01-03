# Install Homebrew

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew update
brew upgrade

brew tap homebrew/bundle
brew tap homebrew/cask-versions
brew tap homebrew/services
brew tap laishulu/homebrew
brew tap microsoft/git

# Install packages
brew install bat
brew install bat-extras
brew install cargo-c
brew install clipboard
brew install codex
brew install curl
brew install curlie
brew install diff-so-fancy
brew install difftastic
brew install diffnav
brew install eza
brew install fd
brew install fzf
brew install gh
brew install git
brew install git-delta
brew install gum
brew install htop
brew install httpie
brew install jq
brew install jsonlint
brew install lua-language-server
brew install luarocks
brew install macism
brew install neovim
brew install node
brew install nowplaying-cli
brew install nvm
brew install pngpast
brew install postgresql
brew install prettierd
brew install pyenv
brew install qemu
brew install readline sqlite3 xz zlib tcl-tk
brew install ripgrep
brew install rust
brew install selene
brew install sharship
brew install shellcheck
brew install sketchybar
brew install spotify_player
brew install stow
brew install tmux
brew install wget
brew install wget
brew install yamllint
brew install yarn
brew install yazi
brew install zoxide

sleep 1

echo "Basic brew packages are installed."

# Cask packages
brew install --cask figma
brew install --cask firefox-developer-edition
brew install --cask font-3270-nerd-font
brew install --cask font-jetbrains-mono-nerd-font
brew install --cask font-monaspace-nerd-font
brew install --cask font-sf-pro
brew install --cask ghostty
brew install --cask google-chrome
brew install --cask hammerspoon
brew install --cask imageoptim
brew install --cask insomnia
brew install --cask keycastr
brew install --cask kitty
brew install --cask nikitabobko/tap/aerospace
brew install --cask obsidian
brew install --cask obsidian
brew install --cask pgadmin4
brew install --cask sf-symbols
brew install --cask spotify
brew install --cask visual-studio-code
brew install --cask zoom
