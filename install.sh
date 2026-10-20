#!/usr/bin/env bash

set -eo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="$DOTFILES/common/.config/brew/Brewfile"
NO_GUI=false
IN_CODESPACES=false
# dotstate release installed on Linux, where its Homebrew tap has no binaries.
# Checksums are pinned here so a replaced release asset is rejected.
DOTSTATE_VERSION="0.4.1"
DOTSTATE_SHA256_X86_64="310e06346f365defe69f8fc9207563618a27fc91bf5cfae276003a6c602fa506"
DOTSTATE_SHA256_AARCH64="85adcb113a1b57e91f5cd9eb25ab54a9ffeebecf9ca5d84025a4471a4030ce39"

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

# Download an installer script to a temp file, then run it with an interpreter.
# Unlike `curl | sh` or `sh -c "$(curl ...)"`, a failed download is an error
# instead of running an empty or truncated script.
# Usage: run_remote_installer <url> <interpreter> [args...]
run_remote_installer() {
    local url="$1" interpreter="$2" script status=0
    shift 2
    script="$(mktemp)"
    if ! curl -fsSL "$url" -o "$script"; then
        rm -f "$script"
        print_error "Failed to download $url"
        return 1
    fi
    "$interpreter" "$script" "$@" || status=$?
    rm -f "$script"
    return "$status"
}

# Setup Codespaces-specific environment
setup_codespaces_environment() {
    if [ "$IN_CODESPACES" != true ]; then
        return
    fi

    print_header "Setting up Codespaces environment..."

    # Ensure USER variable is set
    if [ -z "$USER" ]; then
        USER=$(id -un)
        export USER
        print_info "Set USER=$USER"
    fi

    # Codespaces clones dotfiles to persisted share and symlinks them
    # We need to use the persisted share location for running install scripts
    local PERSISTED_DOTFILES="/workspaces/.codespaces/.persistedshare/dotfiles"

    if [ -d "$PERSISTED_DOTFILES" ]; then
        DOTFILES="$PERSISTED_DOTFILES"
        BREWFILE="$DOTFILES/common/.config/brew/Brewfile"
        print_success "Using dotfiles at: $DOTFILES"
    else
        print_warning "Persisted dotfiles not found at $PERSISTED_DOTFILES"
    fi

    # Change to home directory
    cd "$HOME"
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

# Install Homebrew's Linux bootstrap dependencies
install_linux_homebrew_dependencies() {
    if [ "$OS" != "linux" ] || { command_exists bwrap && command_exists cc; }; then
        return
    fi

    if ! command_exists apt-get; then
        print_warning "Install your distribution's build tools and bubblewrap before using Homebrew"
        return
    fi

    if ! command_exists sudo; then
        print_error "sudo is required to install Homebrew's Linux dependencies"
        return 1
    fi

    print_header "Installing Homebrew dependencies..."
    sudo apt-get update
    sudo apt-get install -y build-essential bubblewrap
    print_success "Homebrew dependencies installed"
}

# Install Homebrew
install_homebrew() {
    # brew may be installed but not on PATH yet (fresh shell on Apple Silicon or Linux)
    if ! command_exists brew; then
        local brew_bin
        for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
            if [ -x "$brew_bin" ]; then
                eval "$("$brew_bin" shellenv)"
                break
            fi
        done
    fi

    if command_exists brew; then
        print_success "Homebrew already installed"
        return
    fi

    print_header "Installing Homebrew..."

    case "$OS" in
        macos)
            run_remote_installer https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh /bin/bash

            # Add Homebrew to PATH for this session
            if [ -d "/opt/homebrew" ]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            else
                eval "$(/usr/local/bin/brew shellenv)"
            fi
            ;;
        linux)
            if [ "$IN_CODESPACES" = true ]; then
                NONINTERACTIVE=1 run_remote_installer https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh /bin/bash
            else
                run_remote_installer https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh /bin/bash
            fi

            if [ -d /home/linuxbrew/.linuxbrew ]; then
                eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

                # Add to shell profiles (only .profile, since .zshenv handles zsh via HOMEBREW_PREFIX)
                # shellcheck disable=SC2016
                if ! grep -q "linuxbrew" "$HOME/.profile" 2>/dev/null; then
                    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$HOME/.profile"
                fi
            fi
            ;;
    esac

    print_success "Homebrew installed"
}

# Bootstrap Homebrew's Linux runtime before installing the full Codespaces Brewfile
bootstrap_codespaces_homebrew() {
    if [ "$IN_CODESPACES" != true ]; then
        return
    fi

    local dependencies
    local action
    local formula
    local formulae=""
    local installed_version
    local outdated

    print_header "Bootstrapping Homebrew toolchain for Codespaces..."

    if ! dependencies="$(brew deps --topological glibc gcc)"; then
        print_error "Could not resolve Homebrew's glibc and GCC dependencies"
        return 1
    fi

    while IFS= read -r formula; do
        if [ -z "$formula" ] || printf '%s\n' "$formulae" | grep -Fx -- "$formula" >/dev/null; then
            continue
        fi
        formulae+="${formulae:+$'\n'}$formula"
    done <<EOF
$dependencies
glibc
gcc
EOF

    while IFS= read -r formula; do
        installed_version="$(brew list --versions "$formula" 2>/dev/null || true)"
        if [ -z "$installed_version" ]; then
            action="install"
        else
            outdated="$(brew outdated --quiet --formula "$formula" 2>/dev/null || true)"
            if [ -z "$outdated" ]; then
                continue
            fi
            action="upgrade"
        fi

        print_info "Running Homebrew $action for bootstrap formula: $formula"
        if ! HOMEBREW_DOWNLOAD_CONCURRENCY=1 HOMEBREW_NO_INSTALL_CLEANUP=1 brew "$action" --formula "$formula" </dev/null; then
            print_error "Failed to $action Homebrew bootstrap formula: $formula"
            return 1
        fi
    done <<< "$formulae"

    print_success "Homebrew toolchain bootstrapped"
}

# Install Linux Brewfile entries without Homebrew Bundle's parallel prefetch.
install_linux_brew_packages() {
    local entry
    local formulae
    local taps

    if ! taps="$(brew bundle list --tap --file="$BREWFILE")"; then
        print_error "Could not read taps from Brewfile: $BREWFILE"
        return 1
    fi

    while IFS= read -r entry; do
        [ -z "$entry" ] && continue

        print_info "Installing Homebrew tap: $entry"
        if ! brew tap "$entry" </dev/null; then
            print_error "Failed to install Homebrew tap: $entry"
            return 1
        fi
    done <<< "$taps"

    if ! formulae="$(brew bundle list --formula --file="$BREWFILE")"; then
        print_error "Could not read formulae from Brewfile: $BREWFILE"
        return 1
    fi

    while IFS= read -r entry; do
        [ -z "$entry" ] && continue

        print_info "Installing Homebrew formula: $entry"
        if ! HOMEBREW_DOWNLOAD_CONCURRENCY=1 HOMEBREW_NO_INSTALL_CLEANUP=1 brew install --formula "$entry" </dev/null; then
            print_error "Failed to install Homebrew formula: $entry"
            return 1
        fi
    done <<< "$formulae"
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
    # Keep the existing .zshrc (dotstate backs it up when linking) and do not switch or start shells
    KEEP_ZSHRC=yes RUNZSH=no CHSH=no \
        run_remote_installer https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh sh --unattended
    print_success "oh-my-zsh installed"
}

# Clone custom oh-my-zsh plugins. Keep in sync with github_plugins in
# .config/zsh/oh-my-zsh.zsh (checked by test.sh).
ZSH_GITHUB_PLUGINS=(
    zsh-users/zsh-autosuggestions
    zsh-users/zsh-syntax-highlighting
    z-shell/zsh-eza
    jeffreytse/zsh-vi-mode
)

install_zsh_plugins() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        print_warning "oh-my-zsh not installed, skipping zsh plugins"
        return
    fi

    local plugins_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
    local plugin name
    mkdir -p "$plugins_dir"

    for plugin in "${ZSH_GITHUB_PLUGINS[@]}"; do
        name="${plugin#*/}"
        if [ -d "$plugins_dir/$name" ]; then
            print_success "zsh plugin $name already installed"
            continue
        fi
        git clone --depth 1 --recursive "https://github.com/$plugin.git" "$plugins_dir/$name"
        print_success "zsh plugin $name installed"
    done
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
    if ! grep -Fxq "$ZSH_PATH" /etc/shells 2>/dev/null; then
        echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
    fi

    if command_exists chsh; then
        if [ "$IN_CODESPACES" = true ]; then
            if sudo chsh -s "$ZSH_PATH" "$(whoami)"; then
                print_success "Default shell set to zsh (takes effect on next login)"
            else
                print_warning "Could not change default shell. Try manually: sudo chsh -s $ZSH_PATH $(whoami)"
            fi
        elif chsh -s "$ZSH_PATH"; then
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

    if [ "$OS" = "linux" ]; then
        print_header "Installing Linux CLI packages sequentially..."
        if ! install_linux_brew_packages; then
            print_error "Homebrew failed to install Linux packages from: $BREWFILE"
            return 1
        fi
        print_success "Linux CLI packages installed"
    elif [ "$NO_GUI" = true ]; then
        print_header "Installing CLI packages only (skipping GUI applications)..."
        local casks
        # HOMEBREW_BUNDLE_CASK_SKIP takes space-separated cask names, not a boolean
        if ! casks="$(brew bundle list --cask --file="$BREWFILE")"; then
            print_error "Could not read casks from Brewfile: $BREWFILE"
            return 1
        fi
        if ! HOMEBREW_DOWNLOAD_CONCURRENCY=1 HOMEBREW_NO_INSTALL_CLEANUP=1 HOMEBREW_BUNDLE_CASK_SKIP="${casks//$'\n'/ }" brew bundle --jobs=1 --file="$BREWFILE"; then
            print_error "Homebrew failed to install CLI packages from: $BREWFILE"
            return 1
        fi
        print_success "CLI packages installed"
    else
        print_header "Installing all packages from Brewfile..."
        if ! HOMEBREW_DOWNLOAD_CONCURRENCY=1 HOMEBREW_NO_INSTALL_CLEANUP=1 brew bundle --jobs=1 --file="$BREWFILE"; then
            print_error "Homebrew failed to install packages from: $BREWFILE"
            return 1
        fi
        print_success "All packages installed"
    fi

    print_info "Cleaning up Homebrew cache..."
    if brew cleanup; then
        print_success "Homebrew cache cleaned"
    else
        print_warning "Homebrew cleanup failed; installed packages are unaffected"
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
    if run_remote_installer https://astral.sh/uv/install.sh sh; then
        print_success "UV installed"
    else
        print_warning "UV installation failed (may not be available in this environment)"
    fi
}

# Install OpenCode
install_opencode() {
    if command_exists opencode; then
        print_success "OpenCode already installed"
        return
    fi

    print_header "Installing OpenCode..."
    if run_remote_installer https://opencode.ai/install bash; then
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

    # Skip extension installation in Codespaces
    if [ "$IN_CODESPACES" = true ]; then
        print_info "Skipping gh extensions in Codespaces"
        return
    fi

    # Check if we're authenticated (required for extension installation)
    if ! gh auth status >/dev/null 2>&1; then
        print_warning "gh not authenticated, skipping extensions (set GH_TOKEN in CI)"
        return
    fi

    local extensions_file="$DOTFILES/common/.config/gh/extensions"

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
        if gh extension list 2>/dev/null | grep -F -- "$extension" >/dev/null; then
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

# Install dotstate on Linux from its pinned release (macOS gets it from the Brewfile)
install_dotstate() {
    if command_exists dotstate; then
        print_success "dotstate already installed"
        return
    fi

    if [ "$OS" != "linux" ]; then
        print_error "dotstate is not installed; it should come from the Brewfile"
        return 1
    fi

    local arch expected
    case "$(uname -m)" in
        x86_64) arch="x86_64"; expected="$DOTSTATE_SHA256_X86_64" ;;
        aarch64|arm64) arch="aarch64"; expected="$DOTSTATE_SHA256_AARCH64" ;;
        *)
            print_error "No dotstate release for architecture: $(uname -m)"
            return 1
            ;;
    esac

    print_header "Installing dotstate $DOTSTATE_VERSION..."

    local asset="dotstate-$arch-unknown-linux-musl.tar.gz"
    local url="https://github.com/serkanyersen/dotstate/releases/download/v$DOTSTATE_VERSION/$asset"
    local tmp actual
    tmp="$(mktemp -d)"

    if ! curl -fsSL "$url" -o "$tmp/$asset"; then
        rm -rf "$tmp"
        print_error "Failed to download $url"
        return 1
    fi

    actual="$(sha256sum "$tmp/$asset" | awk '{print $1}')"
    if [ "$expected" != "$actual" ]; then
        rm -rf "$tmp"
        print_error "Checksum mismatch for $asset"
        return 1
    fi

    mkdir -p "$HOME/.local/bin"
    tar -xzf "$tmp/$asset" -C "$tmp"
    install -m 755 "$tmp/dotstate" "$HOME/.local/bin/dotstate"
    rm -rf "$tmp"

    case ":$PATH:" in
        *":$HOME/.local/bin:"*) ;;
        *) export PATH="$HOME/.local/bin:$PATH" ;;
    esac

    print_success "dotstate installed to ~/.local/bin"
}

# Move untracked state left at pre-dotstate paths (e.g. .config/zsh/secrets.zsh,
# herdr sessions, tmux plugins) into the common/ or macos/ directory that is now
# linked in its place. Apps the manifest does not link (no such directory under
# common/ or a profile) stay put.
migrate_legacy_state() {
    [ -d "$DOTFILES/.config" ] || return 0

    local app dir
    for app in "$DOTFILES"/.config/*/; do
        app="$(basename "$app")"
        for dir in common macos linux; do
            if [ -d "$DOTFILES/$dir/.config/$app" ]; then
                merge_legacy_dir "$DOTFILES/.config/$app" "$DOTFILES/$dir/.config/$app" ".config/$app"
                break
            fi
        done
    done

    find "$DOTFILES/.config" -depth -type d -empty -delete
}

# Move every entry of $1 into $2 without replacing anything already there.
# Usage: merge_legacy_dir <src> <dst> <label>
merge_legacy_dir() {
    local src="$1" dst="$2" label="$3" entry name
    for entry in "$src"/* "$src"/.[!.]* "$src"/..?*; do
        [ -e "$entry" ] || [ -L "$entry" ] || continue
        name="$(basename "$entry")"
        if [ -d "$entry" ] && [ ! -L "$entry" ] && [ -d "$dst/$name" ] && [ ! -L "$dst/$name" ]; then
            merge_legacy_dir "$entry" "$dst/$name" "$label/$name"
        elif [ -e "$dst/$name" ] || [ -L "$dst/$name" ]; then
            print_warning "Not moving $label/$name: it already exists in ${dst#"$DOTFILES"/}"
        else
            mv "$entry" "$dst/$name"
            echo "  Moved $label/$name to ${dst#"$DOTFILES"/}/"
        fi
    done
}

# Stow folded whole directories into links to the repository. dotstate creates
# parent directories itself, so drop such links once they dangle and refuse to
# write through ones that still resolve into the repository.
remove_legacy_parent_links() {
    local dir target
    for dir in .config .pi .pi/agent .agents .agents/skills; do
        [ -L "$HOME/$dir" ] || continue
        target="$(readlink "$HOME/$dir")"
        case "$target" in
            *"$(basename "$DOTFILES")"/*) ;;
            *) continue ;;
        esac
        if [ ! -e "$HOME/$dir" ]; then
            rm "$HOME/$dir"
            print_info "Removed stale Stow link ~/$dir"
        else
            print_error "$HOME/$dir links into the repository ($target); replace it with a real directory first"
            return 1
        fi
    done
}

# Link dotfiles into $HOME with dotstate. Conflicting files and stale links
# (e.g. from the old Stow setup) are backed up to ~/.dotstate-backups/.
link_dotfiles() {
    if ! command_exists dotstate; then
        print_error "dotstate is not installed. Please install it first."
        return 1
    fi

    print_header "Linking dotfiles with dotstate..."

    migrate_legacy_state
    remove_legacy_parent_links

    local config="$HOME/.config/dotstate/config.toml"

    # First-time setup is TUI-only in dotstate, so write a Local-mode config
    # that uses this checkout and its existing git credentials.
    if [ ! -f "$config" ]; then
        mkdir -p "$(dirname "$config")"
        cat > "$config" <<EOF
repo_mode = "Local"
repo_path = "$DOTFILES"
active_profile = "$OS"
backup_enabled = true
EOF
        print_info "Created $config (profile: $OS)"
    elif ! grep -Fqx "repo_path = \"$DOTFILES\"" "$config"; then
        print_warning "$config uses another repository; not linking $DOTFILES"
        return
    fi

    dotstate activate

    # activate is a no-op once a profile is active, so let doctor --fix
    # re-activate to link paths added to the manifest since. Its exit code
    # counts issues found before fixing, so check health with a second run.
    local doctor_log
    doctor_log="$(mktemp)"
    dotstate doctor --fix --no-colors >/dev/null 2>&1 || true
    if ! dotstate doctor --no-colors >"$doctor_log" 2>&1; then
        cat "$doctor_log"
        print_warning "dotstate doctor still reports errors (e.g. links for paths removed from the manifest); fix them with dotstate doctor"
    fi
    rm -f "$doctor_log"

    print_success "Dotfiles linked"
}

# Install trusted Herd (herdr) plugins
install_herdr_plugins() {
    if [ -n "${CI:-}" ]; then
        print_info "CI environment detected, skipping herdr plugin installation"
        return
    fi

    if ! command_exists herdr; then
        print_warning "herdr not installed, skipping plugin installation"
        return
    fi

    if ! command_exists jq; then
        print_error "jq is required to manage herdr plugins but is not installed"
        return 1
    fi

    print_header "Installing herdr plugins..."

    local herdr_plugins=(
        "persiyanov.reviewr:persiyanov/herdr-reviewr"
        "worktrunk:devashish2203/herdr-worktrunk"
        "dutifuldev.ghzinga:dutifuldev/ghzinga/plugins/herdr"
    )

    local installed_json
    if ! installed_json="$(herdr plugin list --json </dev/null)"; then
        print_error "Failed to list installed herdr plugins"
        return 1
    fi

    if ! printf '%s' "$installed_json" | jq -e '
            (type == "object")
            and (.result.plugins | type == "array")
            and (.result.plugins | all(type == "object" and (.plugin_id | type == "string")))
        ' >/dev/null 2>&1; then
        print_error "herdr plugin list --json returned malformed or unexpected JSON"
        return 1
    fi

    local errors=0
    local entry
    local plugin_id
    local plugin_source

    for entry in "${herdr_plugins[@]}"; do
        plugin_id="${entry%%:*}"
        plugin_source="${entry#*:}"

        if printf '%s' "$installed_json" | jq -e --arg id "$plugin_id" \
            'any(.result.plugins[]; .plugin_id == $id)' >/dev/null 2>&1; then
            print_success "herdr plugin already installed: $plugin_id"
            continue
        fi

        print_info "Installing herdr plugin: $plugin_id ($plugin_source)"
        if herdr plugin install "$plugin_source" --yes </dev/null; then
            print_success "herdr plugin installed: $plugin_id"
        else
            print_error "Failed to install herdr plugin: $plugin_id ($plugin_source)"
            errors=$((errors + 1))
        fi
    done

    if [ $errors -gt 0 ]; then
        return 1
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
        echo "  • Put credentials and machine-specific Git settings in ~/.gitconfig.local"
        echo "    (git config --file ~/.gitconfig.local ...); ~/.gitconfig is tracked"
        echo "  • Put secret exports in ~/.config/zsh/secrets.zsh (gitignored)"
        echo ""
    fi
}

# Main installation flow
main() {
    parse_args "$@"

    setup_codespaces_environment

    echo -e "${MAGENTA}"
    echo "╔════════════════════════════════════════╗"
    echo "║     Dotfiles Setup & Installation     ║"
    echo "║                                        ║"
    echo "║  This will install development tools   ║"
    echo "║  and configure your environment        ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"

    detect_os
    install_linux_homebrew_dependencies
    install_homebrew
    bootstrap_codespaces_homebrew
    install_brew_packages
    install_gh_extensions
    set_zsh_default
    install_oh_my_zsh
    install_zsh_plugins
    install_tpm
    install_uv
    install_opencode
    install_dotstate
    link_dotfiles
    install_herdr_plugins
    print_summary
}

# Run main function (skip when this script is sourced, e.g. by test.sh)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
