# Get dotfiles dir (so run this script from anywhere)
export DOTFILES_DIR EXTRA_DIR
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install brew with packages & casks, composer and yarn global packages
. "$DOTFILES_DIR/install/brew.sh"

# Install UV
sh -c "$(curl -fsSL https://astral.sh/uv/install.sh)"
