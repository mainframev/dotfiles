# Get dotfiles dir (so run this script from anywhere)
export DOTFILES_DIR EXTRA_DIR
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"

# Install oh-my-zsh if not installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo "oh-my-zsh installation complete."
else
    echo "oh-my-zsh already installed, skipping."
fi

# Install Homebrew if not installed
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "Homebrew installation complete."
else
    echo "Homebrew already installed, skipping."
fi

# Install brew packages & casks from brewfile
echo "Installing brew packages from Brewfile..."
brew bundle --file="$DOTFILES_DIR/install/brewfile"
echo "Brew packages installation complete."

# Install UV if not installed
if ! command -v uv &> /dev/null; then
    echo "Installing UV..."
    sh -c "$(curl -fsSL https://astral.sh/uv/install.sh)"
    echo "UV installation complete."
else
    echo "UV already installed, skipping."
fi

# Install Claude CLI if not installed
if ! command -v claude &> /dev/null; then
    echo "Installing Claude CLI..."
    curl -fsSL https://claude.ai/install.sh | sh
    echo "Claude CLI installation complete."
else
    echo "Claude CLI already installed, skipping."
fi

# Install OpenCode if not installed: https://opencode.ai/docs
if ! command -v opencode &> /dev/null; then
    echo "Installing OpenCode..."
    curl -fsSL https://opencode.ai/install | sh
    echo "OpenCode installation complete."
else
    echo "OpenCode already installed, skipping."
fi
