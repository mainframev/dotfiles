#!/bin/bash

# Dotfiles Syntax Validation Script
# Tests configuration files for syntax errors before committing

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

echo -e "${BLUE}🧪 Testing dotfiles configuration...${NC}\n"

# Helper function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Test 1: Shell script syntax with shellcheck
echo -e "${BLUE}→ Checking shell scripts...${NC}"
if command_exists shellcheck; then
    SHELL_ERRORS=0

    # Check install.sh
    if [ -f "install.sh" ]; then
        if shellcheck install.sh; then
            echo -e "${GREEN}✓ install.sh passed shellcheck${NC}"
        else
            echo -e "${RED}✗ install.sh has shellcheck issues${NC}"
            SHELL_ERRORS=$((SHELL_ERRORS + 1))
        fi
    fi

    # Check test.sh itself
    if [ -f "test.sh" ]; then
        if shellcheck test.sh; then
            echo -e "${GREEN}✓ test.sh passed shellcheck${NC}"
        else
            echo -e "${RED}✗ test.sh has shellcheck issues${NC}"
            SHELL_ERRORS=$((SHELL_ERRORS + 1))
        fi
    fi

    if [ $SHELL_ERRORS -gt 0 ]; then
        ERRORS=$((ERRORS + SHELL_ERRORS))
    fi
else
    echo -e "${YELLOW}⚠ shellcheck not installed, skipping shell script checks${NC}"
    WARNINGS=$((WARNINGS + 1))
fi
echo

# Test 2: Zsh configuration syntax
echo -e "${BLUE}→ Checking zsh configuration...${NC}"
if command_exists zsh; then
    ZSH_ERRORS=0

    # Check main zsh files
    for file in .zshrc .zshenv .zprofile; do
        if [ -f "$file" ]; then
            if zsh -n "$file" 2>&1; then
                echo -e "${GREEN}✓ $file syntax valid${NC}"
            else
                echo -e "${RED}✗ $file has syntax errors${NC}"
                ZSH_ERRORS=$((ZSH_ERRORS + 1))
            fi
        fi
    done

    # Check .config/zsh/ files
    if [ -d ".config/zsh" ]; then
        ZSH_FILES=$(find .config/zsh -name "*.zsh" -type f)
        ZSH_COUNT=0
        ZSH_FAILED=0

        for file in $ZSH_FILES; do
            ZSH_COUNT=$((ZSH_COUNT + 1))
            if ! zsh -n "$file" 2>/dev/null; then
                if [ $ZSH_FAILED -eq 0 ]; then
                    echo -e "${RED}✗ Zsh files with issues:${NC}"
                fi
                echo -e "  ${RED}• $file${NC}"
                ZSH_FAILED=$((ZSH_FAILED + 1))
            fi
        done

        if [ $ZSH_FAILED -eq 0 ] && [ $ZSH_COUNT -gt 0 ]; then
            echo -e "${GREEN}✓ All $ZSH_COUNT .config/zsh files valid${NC}"
        elif [ $ZSH_FAILED -gt 0 ]; then
            echo -e "${RED}✗ $ZSH_FAILED/$ZSH_COUNT zsh files have issues${NC}"
            ZSH_ERRORS=$((ZSH_ERRORS + 1))
        fi
    fi

    if [ $ZSH_ERRORS -gt 0 ]; then
        ERRORS=$((ERRORS + 1))
    fi
else
    echo -e "${YELLOW}⚠ zsh not installed, skipping zsh checks${NC}"
    WARNINGS=$((WARNINGS + 1))
fi
echo

# Test 3: Git configuration
echo -e "${BLUE}→ Checking git configuration...${NC}"
if command_exists git; then
    GIT_ERRORS=0

    # Check .gitconfig
    if [ -f ".gitconfig" ]; then
        if git config -f .gitconfig --list >/dev/null 2>&1; then
            echo -e "${GREEN}✓ .gitconfig syntax valid${NC}"

            # Verify key sections exist
            if git config -f .gitconfig user.name >/dev/null 2>&1; then
                echo -e "${GREEN}  ✓ user.name configured${NC}"
            else
                echo -e "${YELLOW}  ⚠ user.name not set${NC}"
            fi

            if git config -f .gitconfig --get-regexp "^alias\." >/dev/null 2>&1; then
                ALIAS_COUNT=$(git config -f .gitconfig --get-regexp "^alias\." | wc -l)
                echo -e "${GREEN}  ✓ $ALIAS_COUNT git aliases defined${NC}"
            fi
        else
            echo -e "${RED}✗ .gitconfig has syntax errors${NC}"
            GIT_ERRORS=$((GIT_ERRORS + 1))
        fi
    fi

    # Check delta.gitconfig
    if [ -f "delta.gitconfig" ]; then
        if git config -f delta.gitconfig --list >/dev/null 2>&1; then
            echo -e "${GREEN}✓ delta.gitconfig syntax valid${NC}"
        else
            echo -e "${RED}✗ delta.gitconfig has syntax errors${NC}"
            GIT_ERRORS=$((GIT_ERRORS + 1))
        fi
    fi

    if [ $GIT_ERRORS -gt 0 ]; then
        ERRORS=$((ERRORS + 1))
    fi
else
    echo -e "${YELLOW}⚠ git not installed, skipping git config checks${NC}"
    WARNINGS=$((WARNINGS + 1))
fi
echo

# Test 4: TOML configuration (AeroSpace)
echo -e "${BLUE}→ Checking TOML configurations...${NC}"
if command_exists taplo; then
    TOML_ERRORS=0

    if [ -f ".config/aerospace/aerospace.toml" ]; then
        if taplo check .config/aerospace/aerospace.toml 2>&1; then
            echo -e "${GREEN}✓ aerospace.toml syntax valid${NC}"
        else
            echo -e "${RED}✗ aerospace.toml has syntax errors${NC}"
            TOML_ERRORS=$((TOML_ERRORS + 1))
        fi
    fi

    if [ -f ".config/starship.toml" ]; then
        if taplo check .config/starship.toml 2>&1; then
            echo -e "${GREEN}✓ starship.toml syntax valid${NC}"
        else
            echo -e "${RED}✗ starship.toml has syntax errors${NC}"
            TOML_ERRORS=$((TOML_ERRORS + 1))
        fi
    fi

    if [ $TOML_ERRORS -gt 0 ]; then
        ERRORS=$((ERRORS + 1))
    fi
elif command_exists toml-cli; then
    TOML_ERRORS=0

    if [ -f ".config/aerospace/aerospace.toml" ]; then
        if toml-cli get .config/aerospace/aerospace.toml "" >/dev/null 2>&1; then
            echo -e "${GREEN}✓ aerospace.toml syntax valid${NC}"
        else
            echo -e "${RED}✗ aerospace.toml has syntax errors${NC}"
            TOML_ERRORS=$((TOML_ERRORS + 1))
        fi
    fi

    if [ -f ".config/starship.toml" ]; then
        if toml-cli get .config/starship.toml "" >/dev/null 2>&1; then
            echo -e "${GREEN}✓ starship.toml syntax valid${NC}"
        else
            echo -e "${RED}✗ starship.toml has syntax errors${NC}"
            TOML_ERRORS=$((TOML_ERRORS + 1))
        fi
    fi

    if [ $TOML_ERRORS -gt 0 ]; then
        ERRORS=$((ERRORS + 1))
    fi
else
    echo -e "${YELLOW}⚠ taplo/toml-cli not installed, skipping TOML checks${NC}"
    WARNINGS=$((WARNINGS + 1))
fi
echo

# Test 5: Tmux configuration
echo -e "${BLUE}→ Checking tmux configuration...${NC}"
if command_exists tmux; then
    if [ -f ".config/tmux/tmux.conf" ]; then
        # Basic syntax check - try to parse it
        if tmux -f .config/tmux/tmux.conf list-keys >/dev/null 2>&1; then
            echo -e "${GREEN}✓ tmux.conf syntax valid${NC}"
        else
            echo -e "${YELLOW}⚠ tmux.conf may have issues (or TPM plugins not installed)${NC}"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
else
    echo -e "${YELLOW}⚠ tmux not installed, skipping tmux config checks${NC}"
    WARNINGS=$((WARNINGS + 1))
fi
echo

# Test 6: Homebrew installation serialization
echo -e "${BLUE}→ Checking Homebrew installation serialization...${NC}"
BREW_ERRORS=0
BUNDLE_COMMANDS=$(grep -E 'brew bundle --jobs=1 .*--file=' install.sh || true)

if [ -z "$BUNDLE_COMMANDS" ]; then
    echo -e "${RED}✗ No Homebrew Bundle installation commands found${NC}"
    BREW_ERRORS=$((BREW_ERRORS + 1))
else
    if echo "$BUNDLE_COMMANDS" | grep -vq 'brew bundle --jobs=1'; then
        echo -e "${RED}✗ Homebrew Bundle must use one explicit install job${NC}"
        BREW_ERRORS=$((BREW_ERRORS + 1))
    else
        echo -e "${GREEN}✓ Homebrew Bundle uses one explicit install job${NC}"
    fi

    if echo "$BUNDLE_COMMANDS" | grep -vq 'HOMEBREW_DOWNLOAD_CONCURRENCY=1'; then
        echo -e "${RED}✗ Homebrew downloads must run sequentially${NC}"
        BREW_ERRORS=$((BREW_ERRORS + 1))
    else
        echo -e "${GREEN}✓ Homebrew downloads run sequentially${NC}"
    fi

    if echo "$BUNDLE_COMMANDS" | grep -vq 'HOMEBREW_NO_INSTALL_CLEANUP=1'; then
        echo -e "${RED}✗ Homebrew automatic cleanup must be deferred during bundle installation${NC}"
        BREW_ERRORS=$((BREW_ERRORS + 1))
    else
        echo -e "${GREEN}✓ Homebrew automatic cleanup is deferred during bundle installation${NC}"
    fi
fi

if grep -q '^install_linux_homebrew_dependencies()' install.sh &&
   grep -q 'sudo apt-get install -y build-essential bubblewrap' install.sh &&
   grep -q '^    install_linux_homebrew_dependencies$' install.sh; then
    echo -e "${GREEN}✓ Linux Homebrew prerequisites are installed before packages${NC}"
else
    echo -e "${RED}✗ Linux Homebrew prerequisites must install build-essential and bubblewrap${NC}"
    BREW_ERRORS=$((BREW_ERRORS + 1))
fi

if grep -q '^bootstrap_codespaces_homebrew()' install.sh &&
   grep -q 'brew deps --topological glibc gcc' install.sh; then
    echo -e "${GREEN}✓ Codespaces bootstrap derives the Homebrew toolchain dynamically${NC}"
else
    echo -e "${RED}✗ Codespaces bootstrap must derive glibc and GCC dependencies dynamically${NC}"
    BREW_ERRORS=$((BREW_ERRORS + 1))
fi

BOOTSTRAP_INSTALLS=$(grep -F "brew \"\$action\" --formula \"\$formula\"" install.sh || true)
if [ -n "$BOOTSTRAP_INSTALLS" ] &&
   ! echo "$BOOTSTRAP_INSTALLS" | grep -vq 'HOMEBREW_DOWNLOAD_CONCURRENCY=1' &&
   ! echo "$BOOTSTRAP_INSTALLS" | grep -vq 'HOMEBREW_NO_INSTALL_CLEANUP=1' &&
   ! echo "$BOOTSTRAP_INSTALLS" | grep -vq '</dev/null'; then
    echo -e "${GREEN}✓ Codespaces bootstrap formulae install without cache races${NC}"
else
    echo -e "${RED}✗ Codespaces bootstrap must serialize downloads, defer cleanup, and isolate stdin${NC}"
    BREW_ERRORS=$((BREW_ERRORS + 1))
fi

# shellcheck disable=SC2016
if grep -q '^install_linux_brew_packages()' install.sh &&
   grep -q 'brew bundle list --tap --file=' install.sh &&
   grep -q 'brew bundle list --formula --file=' install.sh &&
   grep -Fq 'brew install --formula "$entry"' install.sh &&
   grep -q '^    if \[ "$OS" = "linux" \]; then$' install.sh; then
    echo -e "${GREEN}✓ Linux Brewfile entries bypass parallel bundle prefetch${NC}"
else
    echo -e "${RED}✗ Linux Brewfile entries must install sequentially without bundle prefetch${NC}"
    BREW_ERRORS=$((BREW_ERRORS + 1))
fi

# shellcheck disable=SC2016
LINUX_FORMULA_INSTALLS=$(grep -F 'brew install --formula "$entry"' install.sh || true)
if [ -n "$LINUX_FORMULA_INSTALLS" ] &&
   ! echo "$LINUX_FORMULA_INSTALLS" | grep -vq 'HOMEBREW_DOWNLOAD_CONCURRENCY=1' &&
   ! echo "$LINUX_FORMULA_INSTALLS" | grep -vq 'HOMEBREW_NO_INSTALL_CLEANUP=1' &&
   ! echo "$LINUX_FORMULA_INSTALLS" | grep -vq '</dev/null'; then
    echo -e "${GREEN}✓ Linux formulae install without download or cleanup races${NC}"
else
    echo -e "${RED}✗ Linux formula installs must serialize downloads, defer cleanup, and isolate stdin${NC}"
    BREW_ERRORS=$((BREW_ERRORS + 1))
fi

if grep -Fq "brew outdated --quiet --formula \"\$formula\"" install.sh &&
   grep -q 'action="upgrade"' install.sh; then
    echo -e "${GREEN}✓ Codespaces bootstrap upgrades outdated toolchain formulae${NC}"
else
    echo -e "${RED}✗ Codespaces bootstrap must upgrade outdated toolchain formulae${NC}"
    BREW_ERRORS=$((BREW_ERRORS + 1))
fi

HOMEBREW_LINE=$(grep -n '^    install_homebrew$' install.sh | cut -d: -f1)
BOOTSTRAP_LINE=$(grep -n '^    bootstrap_codespaces_homebrew$' install.sh | cut -d: -f1)
PACKAGES_LINE=$(grep -n '^    install_brew_packages$' install.sh | cut -d: -f1)
if [ -n "$HOMEBREW_LINE" ] && [ -n "$BOOTSTRAP_LINE" ] && [ -n "$PACKAGES_LINE" ] &&
   [ "$HOMEBREW_LINE" -lt "$BOOTSTRAP_LINE" ] && [ "$BOOTSTRAP_LINE" -lt "$PACKAGES_LINE" ]; then
    echo -e "${GREEN}✓ Codespaces bootstrap runs before Brewfile installation${NC}"
else
    echo -e "${RED}✗ Codespaces bootstrap must run after Homebrew and before Brewfile installation${NC}"
    BREW_ERRORS=$((BREW_ERRORS + 1))
fi

CLEANUP_LINE=$(grep -n '^    if brew cleanup; then$' install.sh | cut -d: -f1)
BUNDLE_SUCCESS_LINE=$(grep -n 'print_success "All packages installed"' install.sh | cut -d: -f1)
if [ -n "$CLEANUP_LINE" ] && [ -n "$BUNDLE_SUCCESS_LINE" ] &&
   [ "$BUNDLE_SUCCESS_LINE" -lt "$CLEANUP_LINE" ] &&
   grep -q 'print_warning "Homebrew cleanup failed; installed packages are unaffected"' install.sh; then
    echo -e "${GREEN}✓ Homebrew cleanup runs non-fatally after bundle installation${NC}"
else
    echo -e "${RED}✗ Homebrew cleanup must run non-fatally after successful bundle installation${NC}"
    BREW_ERRORS=$((BREW_ERRORS + 1))
fi

if [ $BREW_ERRORS -gt 0 ]; then
    ERRORS=$((ERRORS + 1))
fi
echo

# Test 7: YAML configuration (GitHub workflows)
echo -e "${BLUE}→ Checking YAML configurations...${NC}"
if command_exists yamllint; then
    YAML_ERRORS=0

    if [ -d ".github/workflows" ]; then
        YAML_FILES=$(find .github/workflows -name "*.yml" -o -name "*.yaml" -type f 2>/dev/null)
        YAML_COUNT=0
        YAML_FAILED=0

        for file in $YAML_FILES; do
            YAML_COUNT=$((YAML_COUNT + 1))
            if ! yamllint -d relaxed "$file" 2>/dev/null; then
                if [ $YAML_FAILED -eq 0 ]; then
                    echo -e "${RED}✗ YAML files with issues:${NC}"
                fi
                echo -e "  ${RED}• $file${NC}"
                YAML_FAILED=$((YAML_FAILED + 1))
            fi
        done

        if [ $YAML_FAILED -eq 0 ] && [ $YAML_COUNT -gt 0 ]; then
            echo -e "${GREEN}✓ All $YAML_COUNT YAML files valid${NC}"
        elif [ $YAML_FAILED -gt 0 ]; then
            echo -e "${RED}✗ $YAML_FAILED/$YAML_COUNT YAML files have issues${NC}"
            YAML_ERRORS=$((YAML_ERRORS + 1))
        fi
    fi

    if [ $YAML_ERRORS -gt 0 ]; then
        ERRORS=$((ERRORS + 1))
    fi
else
    echo -e "${YELLOW}⚠ yamllint not installed, skipping YAML checks${NC}"
    WARNINGS=$((WARNINGS + 1))
fi
echo

# Test 8: Herdr plugin installation behavior
echo -e "${BLUE}→ Checking herdr plugin installation...${NC}"
HERDR_ERRORS=0

# Structural ordering assertion: herdr plugins must install after dotfiles are
# stowed. This checks the literal call order in main(), not internal
# implementation details, so it stays robust across refactors.
STOW_LINE=$(grep -n '^    stow_dotfiles$' install.sh | cut -d: -f1)
HERDR_INSTALL_LINE=$(grep -n '^    install_herdr_plugins$' install.sh | cut -d: -f1)
if [ -n "$STOW_LINE" ] && [ -n "$HERDR_INSTALL_LINE" ] && [ "$STOW_LINE" -lt "$HERDR_INSTALL_LINE" ]; then
    echo -e "${GREEN}✓ herdr plugins install after dotfiles are stowed${NC}"
else
    echo -e "${RED}✗ install_herdr_plugins must run after stow_dotfiles in main${NC}"
    HERDR_ERRORS=$((HERDR_ERRORS + 1))
fi

if [ -f "install.sh" ] && command_exists jq; then
    # Scratch dir lives outside the repo (never under $(pwd)) so a stray
    # leftover can never pollute `git status` or be mistaken for tracked
    # content.
    HERDR_TEST_DIR="$(mktemp -d "${TMPDIR:-/tmp}/herdr-plugin-test.XXXXXX")"
    mkdir -p "$HERDR_TEST_DIR/bin" "$HERDR_TEST_DIR/empty-bin"

    # Interrupt-safe cleanup: remove the scratch dir on normal exit as well as
    # Ctrl-C/SIGTERM, and restore whatever trap (if any) was previously
    # registered instead of blindly clearing it, so we never stomp on an
    # unrelated handler.
    herdr_test8_prev_exit_trap="$(trap -p EXIT)"
    herdr_test8_prev_int_trap="$(trap -p INT)"
    herdr_test8_prev_term_trap="$(trap -p TERM)"
    herdr_test8_cleanup() {
        rm -rf "$HERDR_TEST_DIR"
    }
    trap herdr_test8_cleanup EXIT INT TERM

    # Stub herdr: logs every invocation ("$*") to $HERDR_STUB_LOG and returns
    # scripted results, so tests never touch real Herd state.
    cat > "$HERDR_TEST_DIR/bin/herdr" <<'STUB'
#!/usr/bin/env bash
echo "$*" >> "$HERDR_STUB_LOG"
if [ "$1" = "plugin" ] && [ "$2" = "list" ]; then
    if [ "${HERDR_STUB_LIST_EXIT:-0}" != "0" ]; then
        exit "${HERDR_STUB_LIST_EXIT}"
    fi
    cat "$HERDR_STUB_LIST_JSON_FILE"
    exit 0
elif [ "$1" = "plugin" ] && [ "$2" = "install" ]; then
    if [ -n "${HERDR_STUB_INSTALL_FAIL:-}" ] && [ "$3" = "${HERDR_STUB_INSTALL_FAIL}" ]; then
        exit 1
    fi
    exit 0
else
    echo "unexpected herdr invocation: $*" >&2
    exit 99
fi
STUB
    chmod +x "$HERDR_TEST_DIR/bin/herdr"

    # Runs install_herdr_plugins in an isolated subshell (its own PATH, env,
    # and `set -e`) so sourcing install.sh cannot affect this test script.
    run_herdr_scenario() {
        # $1=list json, $2=list exit code, $3=install source to fail (or ""),
        # $4=full PATH override (defaults to the stub bin dir prefixed onto
        # the current PATH, so real jq is still reachable), $5=CI value
        : > "$HERDR_TEST_DIR/log"
        printf '%s' "$1" > "$HERDR_TEST_DIR/list.json"
        (
            export PATH="${4:-$HERDR_TEST_DIR/bin:$PATH}"
            export HERDR_STUB_LOG="$HERDR_TEST_DIR/log"
            export HERDR_STUB_LIST_JSON_FILE="$HERDR_TEST_DIR/list.json"
            export HERDR_STUB_LIST_EXIT="$2"
            export HERDR_STUB_INSTALL_FAIL="$3"
            if [ -n "${5:-}" ]; then
                export CI="$5"
            else
                unset CI
            fi
            # shellcheck source=/dev/null
            source ./install.sh
            install_herdr_plugins
        )
    }

    # shellcheck source=/dev/null
    if (unset CI; source ./install.sh; declare -F install_herdr_plugins >/dev/null); then
        echo -e "${GREEN}✓ install_herdr_plugins function defined${NC}"
    else
        echo -e "${RED}✗ install_herdr_plugins function is missing${NC}"
        HERDR_ERRORS=$((HERDR_ERRORS + 1))
    fi

    # Scenario A: one plugin already installed (exact-match only; a
    # similarly-named decoy must NOT be treated as a match), the other two
    # missing and installed with their exact sources and --yes. Uses the real
    # `herdr plugin list --json` envelope shape:
    # {"id":"cli:plugin","result":{"plugins":[...]}}
    MIXED_JSON='{"id":"cli:plugin","result":{"plugins":[{"plugin_id":"persiyanov.reviewr","source":"decoy"},{"plugin_id":"worktrunk-extra","source":"decoy"}]}}'
    if run_herdr_scenario "$MIXED_JSON" 0 ""; then SCENARIO_A_STATUS=0; else SCENARIO_A_STATUS=$?; fi
    LIST_CALLS=$(grep -c '^plugin list --json$' "$HERDR_TEST_DIR/log" || true)
    INSTALL_CALLS=$(grep -c '^plugin install ' "$HERDR_TEST_DIR/log" || true)
    if [ "$SCENARIO_A_STATUS" -eq 0 ] && [ "$LIST_CALLS" -eq 1 ]; then
        echo -e "${GREEN}✓ herdr plugin list --json is invoked exactly once${NC}"
    else
        echo -e "${RED}✗ herdr plugin list --json must be invoked exactly once (found $LIST_CALLS, status $SCENARIO_A_STATUS)${NC}"
        HERDR_ERRORS=$((HERDR_ERRORS + 1))
    fi
    if grep -Fxq 'plugin install devashish2203/herdr-worktrunk --yes' "$HERDR_TEST_DIR/log" &&
       grep -Fxq 'plugin install dutifuldev/ghzinga/plugins/herdr --yes' "$HERDR_TEST_DIR/log" &&
       ! grep -Fq 'persiyanov/herdr-reviewr' "$HERDR_TEST_DIR/log" &&
       [ "$INSTALL_CALLS" -eq 2 ]; then
        echo -e "${GREEN}✓ missing plugins are installed with their exact source and --yes; installed plugin is skipped (exact ID match)${NC}"
    else
        echo -e "${RED}✗ install_herdr_plugins must install exactly the missing sources with --yes and skip already-installed plugins by exact ID${NC}"
        HERDR_ERRORS=$((HERDR_ERRORS + 1))
    fi

    # Scenario B: herdr plugin list --json fails -> nonzero return, no
    # installs attempted, malformed data must not be treated as "all missing".
    if run_herdr_scenario "" 1 ""; then SCENARIO_B_STATUS=0; else SCENARIO_B_STATUS=$?; fi
    LIST_CALLS_B=$(grep -c '^plugin list --json$' "$HERDR_TEST_DIR/log" || true)
    INSTALL_CALLS_B=$(grep -c '^plugin install ' "$HERDR_TEST_DIR/log" || true)
    if [ "$SCENARIO_B_STATUS" -ne 0 ] && [ "$LIST_CALLS_B" -eq 1 ] && [ "$INSTALL_CALLS_B" -eq 0 ]; then
        echo -e "${GREEN}✓ a failed plugin list returns nonzero without attempting installs${NC}"
    else
        echo -e "${RED}✗ a failed herdr plugin list --json must return nonzero and skip installs${NC}"
        HERDR_ERRORS=$((HERDR_ERRORS + 1))
    fi

    # Scenario C: malformed/unexpected JSON (missing .result.plugins array,
    # or a .result.plugins array with malformed entries) must be a visible
    # error with a nonzero return, not "every plugin is missing". Covers a
    # legacy top-level-array shape, an object missing .result.plugins,
    # outright invalid JSON, a non-object plugin entry, a plugin entry whose
    # plugin_id is not a string, a plugin entry missing plugin_id entirely,
    # and a mix of one well-formed entry alongside one malformed entry.
    SCENARIO_C_OK=1
    for MALFORMED_JSON in \
        '{"not":"an array"}' \
        '[]' \
        '{"result":{}}' \
        'not json' \
        '{"result":{"plugins":["oops"]}}' \
        '{"result":{"plugins":[{"plugin_id":123}]}}' \
        '{"result":{"plugins":[{"source":"no plugin_id here"}]}}' \
        '{"result":{"plugins":[{"plugin_id":"persiyanov.reviewr"},"oops"]}}'; do
        if run_herdr_scenario "$MALFORMED_JSON" 0 ""; then SCENARIO_C_STATUS=0; else SCENARIO_C_STATUS=$?; fi
        INSTALL_CALLS_C=$(grep -c '^plugin install ' "$HERDR_TEST_DIR/log" || true)
        if [ "$SCENARIO_C_STATUS" -eq 0 ] || [ "$INSTALL_CALLS_C" -ne 0 ]; then
            SCENARIO_C_OK=0
            echo -e "${RED}✗ malformed herdr plugin list JSON must be a visible nonzero error, not treated as all-missing (input: $MALFORMED_JSON, status $SCENARIO_C_STATUS, installs $INSTALL_CALLS_C)${NC}"
            HERDR_ERRORS=$((HERDR_ERRORS + 1))
        fi
    done
    if [ "$SCENARIO_C_OK" -eq 1 ]; then
        echo -e "${GREEN}✓ malformed/unexpected herdr plugin list JSON returns nonzero without attempting installs${NC}"
    fi

    # Scenario D: a failed install is surfaced as a nonzero return.
    EMPTY_PLUGINS_JSON='{"id":"cli:plugin","result":{"plugins":[]}}'
    if run_herdr_scenario "$EMPTY_PLUGINS_JSON" 0 "devashish2203/herdr-worktrunk"; then SCENARIO_D_STATUS=0; else SCENARIO_D_STATUS=$?; fi
    INSTALL_CALLS_D=$(grep -c '^plugin install ' "$HERDR_TEST_DIR/log" || true)
    if [ "$SCENARIO_D_STATUS" -ne 0 ] && [ "$INSTALL_CALLS_D" -eq 3 ]; then
        echo -e "${GREEN}✓ a failed plugin install is surfaced with a nonzero return${NC}"
    else
        echo -e "${RED}✗ a failed herdr plugin install must be surfaced with a nonzero return${NC}"
        HERDR_ERRORS=$((HERDR_ERRORS + 1))
    fi

    # Scenario E: CI is set -> function must skip entirely with an
    # informational message, making no herdr calls at all.
    if run_herdr_scenario "$EMPTY_PLUGINS_JSON" 0 "" "" "true"; then SCENARIO_E_STATUS=0; else SCENARIO_E_STATUS=$?; fi
    if [ "$SCENARIO_E_STATUS" -eq 0 ] && [ ! -s "$HERDR_TEST_DIR/log" ]; then
        echo -e "${GREEN}✓ install_herdr_plugins skips herdr entirely when CI is set${NC}"
    else
        echo -e "${RED}✗ install_herdr_plugins must skip herdr calls when CI is set${NC}"
        HERDR_ERRORS=$((HERDR_ERRORS + 1))
    fi

    # Scenario F: herdr itself is unavailable -> warn and skip, no failure.
    if run_herdr_scenario "$EMPTY_PLUGINS_JSON" 0 "" "$HERDR_TEST_DIR/empty-bin:/usr/bin:/bin"; then SCENARIO_F_STATUS=0; else SCENARIO_F_STATUS=$?; fi
    if [ "$SCENARIO_F_STATUS" -eq 0 ] && [ ! -s "$HERDR_TEST_DIR/log" ]; then
        echo -e "${GREEN}✓ install_herdr_plugins warns and skips when herdr is unavailable${NC}"
    else
        echo -e "${RED}✗ install_herdr_plugins must warn and skip when herdr is unavailable${NC}"
        HERDR_ERRORS=$((HERDR_ERRORS + 1))
    fi

    unset -f run_herdr_scenario
    herdr_test8_cleanup
    eval "${herdr_test8_prev_exit_trap:-trap - EXIT}"
    eval "${herdr_test8_prev_int_trap:-trap - INT}"
    eval "${herdr_test8_prev_term_trap:-trap - TERM}"
    unset -f herdr_test8_cleanup
else
    echo -e "${YELLOW}⚠ install.sh or jq not available, skipping herdr plugin behavior tests${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

if [ $HERDR_ERRORS -gt 0 ]; then
    ERRORS=$((ERRORS + 1))
fi
echo

# Test 9: Herdr generated-state ignore rules
echo -e "${BLUE}→ Checking herdr generated-state ignore rules...${NC}"
if command_exists git && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    GITIGNORE_ERRORS=0

    if git check-ignore -q --no-index .config/herdr/plugins.json; then
        echo -e "${GREEN}✓ .config/herdr/plugins.json is ignored${NC}"
    else
        echo -e "${RED}✗ .config/herdr/plugins.json must be ignored${NC}"
        GITIGNORE_ERRORS=$((GITIGNORE_ERRORS + 1))
    fi

    if git check-ignore -q --no-index .config/herdr/plugins/github/some-plugin-dir; then
        echo -e "${GREEN}✓ .config/herdr/plugins/github/ contents are ignored${NC}"
    else
        echo -e "${RED}✗ .config/herdr/plugins/github/ contents must be ignored${NC}"
        GITIGNORE_ERRORS=$((GITIGNORE_ERRORS + 1))
    fi

    if git check-ignore -q --no-index .config/herdr/plugins/config/persiyanov.reviewr/config.toml; then
        echo -e "${RED}✗ persiyanov.reviewr plugin config must NOT be ignored${NC}"
        GITIGNORE_ERRORS=$((GITIGNORE_ERRORS + 1))
    else
        echo -e "${GREEN}✓ persiyanov.reviewr plugin config remains trackable${NC}"
    fi

    if git ls-files --error-unmatch .config/herdr/plugins/config/persiyanov.reviewr/config.toml >/dev/null 2>&1; then
        echo -e "${GREEN}✓ persiyanov.reviewr plugin config is tracked in git${NC}"
    else
        echo -e "${RED}✗ persiyanov.reviewr plugin config must be tracked in git${NC}"
        GITIGNORE_ERRORS=$((GITIGNORE_ERRORS + 1))
    fi

    if git ls-files .config/herdr/plugins.json .config/herdr/plugins/github/ 2>/dev/null | grep -q .; then
        echo -e "${RED}✗ Generated herdr plugin state must not be tracked in git${NC}"
        GITIGNORE_ERRORS=$((GITIGNORE_ERRORS + 1))
    else
        echo -e "${GREEN}✓ Generated herdr plugin state is not tracked in git${NC}"
    fi

    if [ -f ".stow-local-ignore" ] &&
       grep -Fq '^/\.config/herdr/plugins\.json$' .stow-local-ignore &&
       grep -Fq '^/\.config/herdr/plugins/github$' .stow-local-ignore; then
        echo -e "${GREEN}✓ .stow-local-ignore declares narrow rules for generated herdr plugin state${NC}"
    else
        echo -e "${RED}✗ .stow-local-ignore must declare narrow rules for .config/herdr/plugins.json and .config/herdr/plugins/github${NC}"
        GITIGNORE_ERRORS=$((GITIGNORE_ERRORS + 1))
    fi

    if command_exists stow; then
        # Build a minimal package fixture *outside* the repository (never
        # under $(pwd)) containing: generated .config/herdr/plugins.json, a
        # generated .config/herdr/plugins/github/<dir> tree, and the tracked
        # .config/herdr/plugins/config/persiyanov.reviewr/config.toml. Stow
        # this fixture (using a copy of the repository's real
        # .stow-local-ignore, so the actual in-force rules are exercised)
        # into a separate, also-outside-the-repo temp target. This is a real
        # (non-dry-run) Stow operation: if the two generated-state ignore
        # rules were ever removed from .stow-local-ignore, this section would
        # start failing, because Stow would then try to link/conflict on the
        # generated paths below.
        STOW_TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/herdr-stow-test.XXXXXX")"
        STOW_FIXTURE_DIR="$STOW_TEST_ROOT/package"
        STOW_TARGET_DIR="$STOW_TEST_ROOT/target"
        STOW_LOG_FILE="$STOW_TEST_ROOT/stow.log"

        # Interrupt-safe cleanup: remove the scratch tree on normal exit as
        # well as Ctrl-C/SIGTERM, restoring any previously-registered trap
        # instead of clearing it, so we never stomp on an unrelated handler.
        herdr_test9_prev_exit_trap="$(trap -p EXIT)"
        herdr_test9_prev_int_trap="$(trap -p INT)"
        herdr_test9_prev_term_trap="$(trap -p TERM)"
        herdr_test9_cleanup() {
            rm -rf "$STOW_TEST_ROOT"
        }
        trap herdr_test9_cleanup EXIT INT TERM

        mkdir -p "$STOW_FIXTURE_DIR" "$STOW_TARGET_DIR"

        # Copy the repository's real .stow-local-ignore so this test
        # exercises the actual rules in force, not a hand-crafted stand-in.
        cp .stow-local-ignore "$STOW_FIXTURE_DIR/.stow-local-ignore"

        # Tracked plugin config: real copies of the files that must remain
        # linkable.
        mkdir -p "$STOW_FIXTURE_DIR/.config/herdr/plugins/config/persiyanov.reviewr"
        cp .config/herdr/config.toml "$STOW_FIXTURE_DIR/.config/herdr/config.toml"
        cp .config/herdr/plugins/config/persiyanov.reviewr/config.toml \
            "$STOW_FIXTURE_DIR/.config/herdr/plugins/config/persiyanov.reviewr/config.toml"

        # Generated herdr state: never tracked, must never be linked.
        mkdir -p "$STOW_FIXTURE_DIR/.config/herdr/plugins/github/some-plugin-abcdef"
        echo '{"generated":"state"}' > "$STOW_FIXTURE_DIR/.config/herdr/plugins.json"
        echo 'generated' > "$STOW_FIXTURE_DIR/.config/herdr/plugins/github/some-plugin-abcdef/marker"

        # Pre-populate the target as if a previous herdr run already
        # generated its own state there (a differently-named plugin dir and
        # its own plugins.json), so we can also assert Stow never touches or
        # overwrites pre-existing generated state.
        mkdir -p "$STOW_TARGET_DIR/.config/herdr/plugins/github/existing-plugin-123456"
        echo '{"existing":"generated"}' > "$STOW_TARGET_DIR/.config/herdr/plugins.json"
        echo 'existing marker' > "$STOW_TARGET_DIR/.config/herdr/plugins/github/existing-plugin-123456/marker"

        STOW_RESULT=0
        stow --dir="$STOW_FIXTURE_DIR" --target="$STOW_TARGET_DIR" --verbose . \
            >"$STOW_LOG_FILE" 2>&1 || STOW_RESULT=$?

        # Stow may satisfy the tracked config either by symlinking the leaf
        # file directly or by folding one of its ancestor directories (e.g.
        # .config/herdr/plugins/config) into a single symlink. Either way,
        # the canonical path must resolve into the fixture package. Both
        # sides are canonicalized with the same readlink -f, since on macOS
        # $TMPDIR itself resolves through a symlink (/var -> /private/var).
        STOW_FIXTURE_DIR_REAL="$(readlink -f "$STOW_FIXTURE_DIR" 2>/dev/null || echo "$STOW_FIXTURE_DIR")"
        LINKED_CONFIG_LEAF="$STOW_TARGET_DIR/.config/herdr/plugins/config/persiyanov.reviewr/config.toml"
        LINKED_CONFIG_REAL="$(readlink -f "$LINKED_CONFIG_LEAF" 2>/dev/null || true)"
        LINKED_CONFIG_IS_REAL=false
        case "$LINKED_CONFIG_REAL" in
            "$STOW_FIXTURE_DIR_REAL"/*) LINKED_CONFIG_IS_REAL=true ;;
        esac

        if [ "$STOW_RESULT" -eq 0 ]; then
            if grep -q 'plugins\.json' "$STOW_LOG_FILE" || grep -q 'plugins/github' "$STOW_LOG_FILE"; then
                echo -e "${RED}✗ stow must not touch generated .config/herdr/plugins.json or plugins/github${NC}"
                GITIGNORE_ERRORS=$((GITIGNORE_ERRORS + 1))
            elif [ -f "$STOW_TARGET_DIR/.config/herdr/plugins.json" ] &&
                 [ ! -L "$STOW_TARGET_DIR/.config/herdr/plugins.json" ] &&
                 grep -q '"existing"' "$STOW_TARGET_DIR/.config/herdr/plugins.json" &&
                 [ -f "$STOW_TARGET_DIR/.config/herdr/plugins/github/existing-plugin-123456/marker" ] &&
                 [ ! -e "$STOW_TARGET_DIR/.config/herdr/plugins/github/some-plugin-abcdef" ] &&
                 [ "$LINKED_CONFIG_IS_REAL" = true ] &&
                 [ -L "$STOW_TARGET_DIR/.config/herdr/config.toml" ] &&
                 diff -q \
                     "$STOW_TARGET_DIR/.config/herdr/plugins/config/persiyanov.reviewr/config.toml" \
                     .config/herdr/plugins/config/persiyanov.reviewr/config.toml >/dev/null 2>&1; then
                echo -e "${GREEN}✓ real stow run into a temp target: generated herdr plugin state is left untouched (not linked, not overwritten) while tracked plugin config is linked${NC}"
            else
                echo -e "${RED}✗ stow must leave pre-existing generated herdr plugin state untouched and still link .config/herdr/plugins/config/persiyanov.reviewr/config.toml${NC}"
                GITIGNORE_ERRORS=$((GITIGNORE_ERRORS + 1))
            fi
        else
            echo -e "${RED}✗ stow reported conflicts against a target with pre-existing generated herdr plugin state (exit $STOW_RESULT)${NC}"
            cat "$STOW_LOG_FILE"
            GITIGNORE_ERRORS=$((GITIGNORE_ERRORS + 1))
        fi

        herdr_test9_cleanup
        eval "${herdr_test9_prev_exit_trap:-trap - EXIT}"
        eval "${herdr_test9_prev_int_trap:-trap - INT}"
        eval "${herdr_test9_prev_term_trap:-trap - TERM}"
        unset -f herdr_test9_cleanup
    else
        echo -e "${YELLOW}⚠ stow not installed, skipping stow conflict check${NC}"
        WARNINGS=$((WARNINGS + 1))
    fi

    if [ $GITIGNORE_ERRORS -gt 0 ]; then
        ERRORS=$((ERRORS + 1))
    fi
else
    echo -e "${YELLOW}⚠ not inside a git work tree (or git not installed), skipping herdr ignore checks${NC}"
    WARNINGS=$((WARNINGS + 1))
fi
echo

# Test 10: Global AGENTS template and Stow projection
echo -e "${BLUE}→ Checking global AGENTS template...${NC}"
AGENTS_ERRORS=0

if [ -f "AGENTS.md" ]; then
    echo -e "${GREEN}✓ AGENTS.md template exists${NC}"
else
    echo -e "${RED}✗ AGENTS.md template must exist at the repository root${NC}"
    AGENTS_ERRORS=$((AGENTS_ERRORS + 1))
fi

if command_exists git && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    if git check-ignore -q --no-index AGENTS.md; then
        echo -e "${RED}✗ AGENTS.md must not be ignored by Git${NC}"
        AGENTS_ERRORS=$((AGENTS_ERRORS + 1))
    else
        echo -e "${GREEN}✓ AGENTS.md is not ignored by Git${NC}"
    fi

    if git ls-files --error-unmatch AGENTS.md >/dev/null 2>&1; then
        echo -e "${GREEN}✓ AGENTS.md is tracked by Git${NC}"
    else
        echo -e "${RED}✗ AGENTS.md must be tracked by Git${NC}"
        AGENTS_ERRORS=$((AGENTS_ERRORS + 1))
    fi
else
    echo -e "${YELLOW}⚠ not inside a git work tree (or git not installed), skipping AGENTS.md Git checks${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

if command_exists stow; then
    AGENTS_REPOSITORY_DIR="$(pwd -P)"
    AGENTS_TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/agents-stow-test.XXXXXX")"
    AGENTS_PACKAGE_DIR="$AGENTS_TEST_ROOT/package"
    AGENTS_TARGET_DIR="$AGENTS_TEST_ROOT/target"
    AGENTS_HOME_DIR="$AGENTS_TEST_ROOT/home"
    AGENTS_STOW_LOG="$AGENTS_TEST_ROOT/stow.log"
    AGENTS_BACKUP_LOG="$AGENTS_TEST_ROOT/backup.log"

    agents_test10_prev_exit_trap="$(trap -p EXIT)"
    agents_test10_prev_int_trap="$(trap -p INT)"
    agents_test10_prev_term_trap="$(trap -p TERM)"
    agents_test10_cleanup() {
        rm -rf "$AGENTS_TEST_ROOT"
    }
    trap agents_test10_cleanup EXIT INT TERM

    agents_canonical_path() {
        if command_exists realpath; then
            realpath "$1"
        else
            readlink -f "$1"
        fi
    }

    mkdir -p "$AGENTS_PACKAGE_DIR" "$AGENTS_TARGET_DIR" "$AGENTS_HOME_DIR"
    ln -s "$AGENTS_REPOSITORY_DIR" "$AGENTS_TEST_ROOT/repository"
    ln -s "../repository/AGENTS.md" "$AGENTS_PACKAGE_DIR/AGENTS.md"

    AGENTS_STOW_RESULT=0
    stow --dir="$AGENTS_PACKAGE_DIR" --target="$AGENTS_TARGET_DIR" --verbose . \
        >"$AGENTS_STOW_LOG" 2>&1 || AGENTS_STOW_RESULT=$?

    REPOSITORY_AGENTS_REAL="$(agents_canonical_path "$AGENTS_REPOSITORY_DIR/AGENTS.md" 2>/dev/null || true)"
    TARGET_AGENTS_REAL="$(agents_canonical_path "$AGENTS_TARGET_DIR/AGENTS.md" 2>/dev/null || true)"

    if [ "$AGENTS_STOW_RESULT" -eq 0 ] &&
       [ -L "$AGENTS_TARGET_DIR/AGENTS.md" ] &&
       [ -n "$REPOSITORY_AGENTS_REAL" ] &&
       [ "$TARGET_AGENTS_REAL" = "$REPOSITORY_AGENTS_REAL" ]; then
        echo -e "${GREEN}✓ temporary Stow fixture links target/AGENTS.md to the repository template${NC}"
    else
        echo -e "${RED}✗ temporary Stow fixture must link target/AGENTS.md to the repository template${NC}"
        if [ "$AGENTS_STOW_RESULT" -ne 0 ]; then
            cat "$AGENTS_STOW_LOG"
        fi
        AGENTS_ERRORS=$((AGENTS_ERRORS + 1))
    fi

    printf '%s\n' 'pre-existing unmanaged AGENTS' > "$AGENTS_HOME_DIR/AGENTS.md"
    AGENTS_BACKUP_RESULT=0
    (
        export HOME="$AGENTS_HOME_DIR"
        # Sourcing install.sh exposes stow_dotfiles without running main.
        # shellcheck source=install.sh
        # shellcheck disable=SC1091
        source "$AGENTS_REPOSITORY_DIR/install.sh"
        stow_dotfiles
    ) >"$AGENTS_BACKUP_LOG" 2>&1 || AGENTS_BACKUP_RESULT=$?

    AGENTS_BACKUP_FILES="$(find "$AGENTS_HOME_DIR" -type f \
        -path "$AGENTS_HOME_DIR/.dotfiles-backup-*/AGENTS.md" -print)"
    AGENTS_BACKUP_COUNT="$(printf '%s\n' "$AGENTS_BACKUP_FILES" | sed '/^$/d' | wc -l | tr -d ' ')"
    AGENTS_BACKUP_PATH="$(printf '%s\n' "$AGENTS_BACKUP_FILES" | sed -n '1p')"
    AGENTS_BACKUP_DIR_NAME="$(basename "$(dirname "$AGENTS_BACKUP_PATH")")"
    HOME_AGENTS_REAL="$(agents_canonical_path "$AGENTS_HOME_DIR/AGENTS.md" 2>/dev/null || true)"

    if [ "$AGENTS_BACKUP_RESULT" -eq 0 ] &&
       [ "$AGENTS_BACKUP_COUNT" -eq 1 ] &&
       [ -f "$AGENTS_BACKUP_PATH" ] &&
       printf '%s\n' "$AGENTS_BACKUP_DIR_NAME" | grep -Eq '^\.dotfiles-backup-[0-9]{8}-[0-9]{6}$' &&
       grep -qx 'pre-existing unmanaged AGENTS' "$AGENTS_BACKUP_PATH" &&
       [ -L "$AGENTS_HOME_DIR/AGENTS.md" ] &&
       [ "$HOME_AGENTS_REAL" = "$REPOSITORY_AGENTS_REAL" ]; then
        echo -e "${GREEN}✓ stow_dotfiles backs up an unmanaged AGENTS.md and links the repository template${NC}"
    else
        echo -e "${RED}✗ stow_dotfiles must back up an unmanaged AGENTS.md before linking the repository template${NC}"
        cat "$AGENTS_BACKUP_LOG"
        AGENTS_ERRORS=$((AGENTS_ERRORS + 1))
    fi

    agents_test10_cleanup
    eval "${agents_test10_prev_exit_trap:-trap - EXIT}"
    eval "${agents_test10_prev_int_trap:-trap - INT}"
    eval "${agents_test10_prev_term_trap:-trap - TERM}"
    unset -f agents_test10_cleanup
    unset -f agents_canonical_path
else
    echo -e "${YELLOW}⚠ stow not installed, skipping AGENTS.md Stow projection check${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

if [ $AGENTS_ERRORS -gt 0 ]; then
    ERRORS=$((ERRORS + AGENTS_ERRORS))
fi
echo

# Summary
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ Tests passed with $WARNINGS warning(s)${NC}"
    echo -e "${YELLOW}  (Some validation tools not installed)${NC}"
    exit 0
else
    echo -e "${RED}✗ Tests failed with $ERRORS error(s) and $WARNINGS warning(s)${NC}"
    exit 1
fi
