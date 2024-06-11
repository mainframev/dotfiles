# Install Homebrew

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew update
brew upgrade

brew tap homebrew/cask-versions

# Install packages
brew install htop
brew install git
brew install yazi
brew install gh
brew install wget
brew install yarn
brew install pyenv                           # python version manager
brew install readline sqlite3 xz zlib tcl-tk # Python dependencies
brew install fzf
brew install clipboard
brew install cargo-c
brew install bat
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

sleep 1

echo "Basic brew packages are installed."

# cask packages
brew install --cask spotify
brew install --cask insomnia
brew install --cask visual-studio-code
brew install --cask google-chrome
brew install --cask imageoptim
brew install --cask figma
brew install --cask zoom
