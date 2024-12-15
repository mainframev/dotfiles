# Install Homebrew

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew update
brew upgrade

brew tap homebrew/cask-versions
brew tap homebrew/bundle
brew tap homebrew/services
brew tap microsoft/git
brew tap laishulu/homebrew

# Install packages
brew install htop
brew install curl
brew install spotify_player
brew install curlie
brew install git
brew install git-delta
brew install difftastic
brew install yazi
brew install diff-so-fancy
brew install gh
brew install wget
brew install yarn
brew install pyenv
brew install readline sqlite3 xz zlib tcl-tk
brew install fzf
brew install clipboard
brew install cargo-c
brew install bat
brew install bat-extras
brew install prettierd
brew install tmux
brew install qemu
brew install neovim
brew install node
brew install nvm
brew install eza
brew install nowplaying-cli
brew install stow
brew install rust
brew install ripgrep
brew install luarocks
brew install lua-language-server
brew install fd
brew install wget
brew install sketchybar
brew install zoxide
brew install jq
brew install macism

sleep 1

echo "Basic brew packages are installed."

# Cask packages
brew install --cask spotify
brew install --cask insomnia
brew install --cask visual-studio-code
brew install --cask google-chrome
brew install --cask imageoptim
brew install --cask figma
brew install --cask zoom
brew install --cask kitty
brew install --cask nikitabobko/tap/aerospace
brew install --cask sf-symbols
brew install --cask font-sf-pro
brew install --cask hammerspoon
brew install --cask font-jetbrains-mono-nerd-font
brew install --cask font-monaspace-nerd-font
brew install --cask font-3270-nerd-font
brew install --cask obsidian
brew install --cask keycastr
brew install --cask firefox-developer-edition
