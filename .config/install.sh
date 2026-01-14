#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"
BREWFILE="$DOTFILES/.config/brew/Brewfile"
NO_GUI=false
IN_CODESPACES=false

# Detect GitHub Codespaces
if [ -n "$CODESPACES" ]; then
    IN_CODESPACES=true
fi

# Parse command line arguments
parse_args() {
    for arg in "$@"; do
        case $arg in
            --no-gui)
                NO_GUI=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                ;;
        esac
    done

    # Auto-enable --no-gui in Codespaces
    if [ "$IN_CODESPACES" = true ]; then
        NO_GUI=true
    fi
}

# Show help message
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --no-gui    Skip installation of GUI applications (casks)"
    echo "  --help, -h  Show this help message"
    echo ""
    echo "Example:"
    echo "  $0              # Install everything"
    echo "  $0 --no-gui     # Install only CLI tools"
}

# Helper functions
print_header() {
    echo -e "\n${BLUE}==>${NC} ${1}"
}

print_success() {
    echo -e "${GREEN}✓${NC} ${1}"
}

print_warning() {
    echo -e "${YELLOW}!${NC} ${1}"
}

print_error() {
    echo -e "${RED}✗${NC} ${1}"
}

print_info() {
    echo -e "${CYAN}ℹ${NC} ${1}"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Darwin*)
            OS="macos"
            print_success "Detected macOS"
            ;;
        Linux*)
            OS="linux"
            print_success "Detected Linux"
            if [ "$IN_CODESPACES" = true ]; then
                print_info "Running in GitHub Codespaces"
            fi
            ;;
        *)
            print_error "Unsupported operating system"
            exit 1
            ;;
    esac
}

# Install Homebrew
install_homebrew() {
    if command_exists brew; then
        print_success "Homebrew already installed"
        return
    fi

    print_header "Installing Homebrew..."

    case "$OS" in
        macos)
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

            # Add Homebrew to PATH for this session
            if [ -d "/opt/homebrew" ]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            else
                eval "$(/usr/local/bin/brew shellenv)"
            fi
            ;;
        linux)
            if [ "$IN_CODESPACES" = true ]; then
                NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            else
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi

            # Add Homebrew to PATH for Linux
            if [ -d /home/linuxbrew/.linuxbrew ]; then
                eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

                # Add to shell profiles
                # shellcheck disable=SC2016
                if ! grep -q "linuxbrew" "$HOME/.profile" 2>/dev/null; then
                    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$HOME/.profile"
                fi

                if [ -f "$HOME/.zshrc" ]; then
                    # shellcheck disable=SC2016
                    if ! grep -q "linuxbrew" "$HOME/.zshrc"; then
                        echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$HOME/.zshrc"
                    fi
                fi
            fi
            ;;
    esac

    print_success "Homebrew installed"
}

# Install oh-my-zsh
install_oh_my_zsh() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        print_success "oh-my-zsh already installed"
        return
    fi

    if ! command_exists zsh; then
        print_warning "zsh not installed, skipping oh-my-zsh"
        return
    fi

    print_header "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_success "oh-my-zsh installed"
}

# Set zsh as default shell
set_zsh_default() {
    if ! command_exists zsh; then
        print_warning "zsh not found, will be installed via Brewfile"
        return
    fi

    # Compare basename to handle different zsh paths (e.g., /bin/zsh vs /usr/bin/zsh)
    if [ "$(basename "$SHELL")" = "zsh" ]; then
        print_success "zsh is already the default shell"
        return
    fi

    print_header "Setting zsh as default shell..."
    local ZSH_PATH
    ZSH_PATH="$(command -v zsh)"

    # Add zsh to /etc/shells if not present
    if ! grep -q "$ZSH_PATH" /etc/shells 2>/dev/null; then
        echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
    fi

    # Change default shell
    if command_exists chsh; then
        if chsh -s "$ZSH_PATH"; then
            print_success "Default shell set to zsh (takes effect on next login)"
        else
            print_warning "Could not change default shell. Try manually: chsh -s $ZSH_PATH"
        fi
    else
        print_warning "chsh not available. Run manually: chsh -s $ZSH_PATH"
    fi
}

# Install packages from Brewfile
install_brew_packages() {
    if [ ! -f "$BREWFILE" ]; then
        print_error "Brewfile not found at: $BREWFILE"
        exit 1
    fi

    if [ "$NO_GUI" = true ]; then
        print_header "Installing CLI packages only (skipping GUI applications)..."
        # Filter out cask lines from Brewfile
        local temp_brewfile="/tmp/brewfile-no-gui-$$"
        grep -v '^cask' "$BREWFILE" > "$temp_brewfile"
        brew bundle --file="$temp_brewfile"
        rm -f "$temp_brewfile"
        print_success "CLI packages installed"
    else
        print_header "Installing all packages from Brewfile..."
        brew bundle --file="$BREWFILE"
        print_success "All packages installed"
    fi

    # Ensure Homebrew binaries are in PATH (important for CI)
    if command_exists brew; then
        eval "$(brew shellenv)"
    fi
}

# Install tmux plugin manager
install_tpm() {
    local tpm_dir="$HOME/.tmux/plugins/tpm"

    if [ -d "$tpm_dir" ]; then
        print_success "tmux plugin manager already installed"
        return
    fi

    print_header "Installing tmux plugin manager..."
    git clone --depth=1 https://github.com/tmux-plugins/tpm "$tpm_dir"
    print_success "tmux plugin manager installed"
}

# Install UV (Python package manager)
install_uv() {
    if command_exists uv; then
        print_success "UV already installed"
        return
    fi

    print_header "Installing UV..."
    if curl -LsSf https://astral.sh/uv/install.sh | sh; then
        print_success "UV installed"
    else
        print_warning "UV installation failed (may not be available in this environment)"
    fi
}

# Install Claude CLI
install_claude_cli() {
    if command_exists claude; then
        print_success "Claude CLI already installed"
        return
    fi

    print_header "Installing Claude CLI..."
    if curl -fsSL https://claude.ai/install.sh | sh; then
        print_success "Claude CLI installed"
    else
        print_warning "Claude CLI installation failed (may not be available in this environment)"
    fi
}

# Install OpenCode
install_opencode() {
    if command_exists opencode; then
        print_success "OpenCode already installed"
        return
    fi

    print_header "Installing OpenCode..."
    if curl -fsSL https://opencode.ai/install | sh; then
        print_success "OpenCode installed"
    else
        print_warning "OpenCode installation failed (may not be available in this environment)"
    fi
}

# Install GitHub CLI extensions
install_gh_extensions() {
    if ! command_exists gh; then
        print_warning "gh CLI not installed, skipping extensions"
        return
    fi

    # Check if we're authenticated (required for extension installation)
    if ! gh auth status >/dev/null 2>&1; then
        print_warning "gh not authenticated, skipping extensions (set GH_TOKEN in CI)"
        return
    fi

    local extensions_file="$DOTFILES/.config/gh/extensions"

    if [ ! -f "$extensions_file" ]; then
        print_info "No gh extensions file found at $extensions_file"
        return
    fi

    print_header "Installing GitHub CLI extensions..."

    local installed=0
    local skipped=0

    # Read extensions file line by line
    while IFS= read -r extension || [ -n "$extension" ]; do
        # Skip empty lines and comments
        [[ -z "$extension" || "$extension" =~ ^# ]] && continue

        # Trim whitespace
        extension=$(echo "$extension" | xargs)

        # Check if already installed
        if gh extension list 2>/dev/null | grep -q "$extension"; then
            print_success "$extension already installed"
            skipped=$((skipped + 1))
        else
            echo "  Installing $extension..."
            if gh extension install "$extension"; then
                print_success "$extension installed"
                installed=$((installed + 1))
            else
                print_warning "Failed to install $extension"
            fi
        fi
    done < "$extensions_file"

    if [ $installed -eq 0 ] && [ $skipped -eq 0 ]; then
        print_info "No extensions to install"
    else
        echo "  Installed: $installed, Already present: $skipped"
    fi
}

# Stow dotfiles
stow_dotfiles() {
    if ! command_exists stow; then
        print_error "stow is not installed. Please install it first."
        return 1
    fi

    print_header "Stowing dotfiles..."

    # Backup existing dotfiles that might conflict
    local backup_dir
    backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
    local needs_backup=false

    # Common dotfiles that might exist and aren't symlinks
    local common_files=(".zshrc" ".zshenv" ".zprofile" ".gitconfig" ".tmux.conf" ".editorconfig")

    for file in "${common_files[@]}"; do
        if [ -e "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
            if [ "$needs_backup" = false ]; then
                mkdir -p "$backup_dir"
                print_warning "Backing up existing dotfiles to $backup_dir"
                needs_backup=true
            fi
            mv "$HOME/$file" "$backup_dir/"
            echo "  Backed up $file"
        fi
    done

    # Get parent directory and dotfiles name for stow
    local parent_dir
    local dotfiles_name
    parent_dir="$(dirname "$DOTFILES")"
    dotfiles_name="$(basename "$DOTFILES")"

    # Unstow first (in case of previous installation)
    stow --dir="$parent_dir" --target="$HOME" -D "$dotfiles_name" 2>/dev/null || true

    # Stow the dotfiles directory with explicit flags
    stow --dir="$parent_dir" --target="$HOME" --verbose "$dotfiles_name"

    print_success "Dotfiles stowed"

    if [ "$needs_backup" = true ]; then
        print_warning "Your original dotfiles have been backed up to: $backup_dir"
    fi
}

# Print installation summary
print_summary() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗"
    echo "║      Installation Complete! 🎉         ║"
    echo "╚════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Configuration:${NC}"
    echo "  Dotfiles dir: $DOTFILES"
    echo "  Platform:     $OS"
    if [ "$IN_CODESPACES" = true ]; then
        echo "  Environment:  GitHub Codespaces"
    fi
    if [ "$NO_GUI" = true ]; then
        echo "  GUI apps:     Skipped"
    else
        echo "  GUI apps:     Installed"
    fi
    echo ""
    print_warning "Please restart your terminal or run: source ~/.zshrc"
    echo ""

    if [ "$IN_CODESPACES" = true ]; then
        print_info "In Codespaces, you may need to reload your window for changes to take effect"
    fi

    if [ "$OS" = "macos" ]; then
        echo -e "${CYAN}Next steps:${NC}"
        echo "  • Configure your terminal theme"
        echo "  • Set up Git credentials: git config --global user.name 'Your Name'"
        echo "  • Set up Git email: git config --global user.email 'your@email.com'"
        echo ""
    fi
}

# Main installation flow
main() {
    parse_args "$@"

    echo -e "${MAGENTA}"
    echo "╔════════════════════════════════════════╗"
    echo "║     Dotfiles Setup & Installation     ║"
    echo "║                                        ║"
    echo "║  This will install development tools   ║"
    echo "║  and configure your environment        ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"

    detect_os
    install_homebrew
    install_brew_packages
    install_gh_extensions
    install_oh_my_zsh
    set_zsh_default
    install_tpm
    install_uv
    install_claude_cli
    install_opencode
    stow_dotfiles
    print_summary
}

# Run main function
main "$@"
