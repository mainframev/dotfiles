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

# Print the steps of a full install in run order: main runs every component
# in COMPONENTS order, and each component_* function runs its steps in order
install_step_order() {
    # shellcheck disable=SC2016
    grep -qxF '    run_components "${COMPONENTS[@]}"' install.sh || return 1
    bash -c 'source ./install.sh
        for component in "${COMPONENTS[@]}"; do
            declare -f "component_$component" | sed -n "s/^    \([a-z_]*\);*$/\1/p"
        done'
}

INSTALL_STEP_ORDER="$(install_step_order || true)"

# Succeed when install step $1 runs before step $2 in a full install
step_runs_before() {
    local first second
    first="$(grep -nx "$1" <<< "$INSTALL_STEP_ORDER" | cut -d: -f1)"
    second="$(grep -nx "$2" <<< "$INSTALL_STEP_ORDER" | cut -d: -f1)"
    [ -n "$first" ] && [ -n "$second" ] && [ "$first" -lt "$second" ]
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

    # Check the dots CLI
    if [ -f "dots" ]; then
        if shellcheck -x dots; then
            echo -e "${GREEN}✓ dots passed shellcheck${NC}"
        else
            echo -e "${RED}✗ dots has shellcheck issues${NC}"
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
    for file in common/.zshrc common/.zshenv common/.zprofile; do
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
    if [ -d "common/.config/zsh" ]; then
        ZSH_FILES=$(find common/.config/zsh -name "*.zsh" -type f)
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

# Test 2b: zsh plugin lists stay in sync between install.sh and oh-my-zsh.zsh
echo -e "${BLUE}→ Checking zsh plugin lists...${NC}"
extract_plugin_list() {
    # Print entries of the array named $2 in file $1, one per line
    awk -v name="$2" '
        $0 ~ "^[[:space:]]*" name "=\\(" { inside = 1; next }
        inside && /^[[:space:]]*\)/ { exit }
        inside { gsub(/[[:space:]]/, ""); if ($0 != "") print }
    ' "$1"
}
INSTALL_PLUGINS=$(extract_plugin_list install.sh ZSH_GITHUB_PLUGINS)
OMZ_PLUGINS=$(extract_plugin_list common/.config/zsh/oh-my-zsh.zsh github_plugins)
if [ -n "$INSTALL_PLUGINS" ] && [ "$INSTALL_PLUGINS" = "$OMZ_PLUGINS" ]; then
    echo -e "${GREEN}✓ install.sh and oh-my-zsh.zsh plugin lists match${NC}"
else
    echo -e "${RED}✗ zsh plugin lists differ between install.sh and common/.config/zsh/oh-my-zsh.zsh${NC}"
    ERRORS=$((ERRORS + 1))
fi
if grep -q 'git clone' common/.config/zsh/oh-my-zsh.zsh; then
    echo -e "${RED}✗ common/.config/zsh/oh-my-zsh.zsh must not clone plugins at shell startup${NC}"
    ERRORS=$((ERRORS + 1))
fi
echo

# Test 3: Git configuration
echo -e "${BLUE}→ Checking git configuration...${NC}"
if command_exists git; then
    GIT_ERRORS=0

    # Check .gitconfig
    if [ -f "common/.gitconfig" ]; then
        if git config -f common/.gitconfig --list >/dev/null 2>&1; then
            echo -e "${GREEN}✓ .gitconfig syntax valid${NC}"

            # Verify key sections exist
            if git config -f common/.gitconfig user.name >/dev/null 2>&1; then
                echo -e "${GREEN}  ✓ user.name configured${NC}"
            else
                echo -e "${YELLOW}  ⚠ user.name not set${NC}"
            fi

            if git config -f common/.gitconfig --get-regexp "^alias\." >/dev/null 2>&1; then
                ALIAS_COUNT=$(git config -f common/.gitconfig --get-regexp "^alias\." | wc -l)
                echo -e "${GREEN}  ✓ $ALIAS_COUNT git aliases defined${NC}"
            fi
        else
            echo -e "${RED}✗ .gitconfig has syntax errors${NC}"
            GIT_ERRORS=$((GIT_ERRORS + 1))
        fi
    fi

    # Check delta.gitconfig
    if [ -f "common/delta.gitconfig" ]; then
        if git config -f common/delta.gitconfig --list >/dev/null 2>&1; then
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

    if [ -f "macos/.config/aerospace/aerospace.toml" ]; then
        if taplo check macos/.config/aerospace/aerospace.toml 2>&1; then
            echo -e "${GREEN}✓ aerospace.toml syntax valid${NC}"
        else
            echo -e "${RED}✗ aerospace.toml has syntax errors${NC}"
            TOML_ERRORS=$((TOML_ERRORS + 1))
        fi
    fi

    if [ -f "common/.config/starship.toml" ]; then
        if taplo check common/.config/starship.toml 2>&1; then
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

    if [ -f "macos/.config/aerospace/aerospace.toml" ]; then
        if toml-cli get macos/.config/aerospace/aerospace.toml "" >/dev/null 2>&1; then
            echo -e "${GREEN}✓ aerospace.toml syntax valid${NC}"
        else
            echo -e "${RED}✗ aerospace.toml has syntax errors${NC}"
            TOML_ERRORS=$((TOML_ERRORS + 1))
        fi
    fi

    if [ -f "common/.config/starship.toml" ]; then
        if toml-cli get common/.config/starship.toml "" >/dev/null 2>&1; then
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
    if [ -f "common/.config/tmux/tmux.conf" ]; then
        # Basic syntax check - try to parse it
        if tmux -f common/.config/tmux/tmux.conf list-keys >/dev/null 2>&1; then
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
# linked
if step_runs_before link_dotfiles install_herdr_plugins; then
    echo -e "${GREEN}✓ herdr plugins install after dotfiles are linked${NC}"
else
    echo -e "${RED}✗ install_herdr_plugins must run after link_dotfiles in a full install${NC}"
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

    if git check-ignore -q --no-index common/.config/herdr/plugins.json; then
        echo -e "${GREEN}✓ common/.config/herdr/plugins.json is ignored${NC}"
    else
        echo -e "${RED}✗ common/.config/herdr/plugins.json must be ignored${NC}"
        GITIGNORE_ERRORS=$((GITIGNORE_ERRORS + 1))
    fi

    if git check-ignore -q --no-index common/.config/herdr/plugins/github/some-plugin-dir; then
        echo -e "${GREEN}✓ common/.config/herdr/plugins/github/ contents are ignored${NC}"
    else
        echo -e "${RED}✗ common/.config/herdr/plugins/github/ contents must be ignored${NC}"
        GITIGNORE_ERRORS=$((GITIGNORE_ERRORS + 1))
    fi

    if git check-ignore -q --no-index common/.config/herdr/plugins/config/persiyanov.reviewr/config.toml; then
        echo -e "${RED}✗ persiyanov.reviewr plugin config must NOT be ignored${NC}"
        GITIGNORE_ERRORS=$((GITIGNORE_ERRORS + 1))
    else
        echo -e "${GREEN}✓ persiyanov.reviewr plugin config remains trackable${NC}"
    fi

    if git ls-files --error-unmatch common/.config/herdr/plugins/config/persiyanov.reviewr/config.toml >/dev/null 2>&1; then
        echo -e "${GREEN}✓ persiyanov.reviewr plugin config is tracked in git${NC}"
    else
        echo -e "${RED}✗ persiyanov.reviewr plugin config must be tracked in git${NC}"
        GITIGNORE_ERRORS=$((GITIGNORE_ERRORS + 1))
    fi

    if git ls-files common/.config/herdr/plugins.json common/.config/herdr/plugins/github/ 2>/dev/null | grep -q .; then
        echo -e "${RED}✗ Generated herdr plugin state must not be tracked in git${NC}"
        GITIGNORE_ERRORS=$((GITIGNORE_ERRORS + 1))
    else
        echo -e "${GREEN}✓ Generated herdr plugin state is not tracked in git${NC}"
    fi

    if [ $GITIGNORE_ERRORS -gt 0 ]; then
        ERRORS=$((ERRORS + 1))
    fi
else
    echo -e "${YELLOW}⚠ not inside a git work tree (or git not installed), skipping herdr ignore checks${NC}"
    WARNINGS=$((WARNINGS + 1))
fi
echo

# Test 10: Repository and global AGENTS instructions
echo -e "${BLUE}→ Checking AGENTS instruction files...${NC}"
AGENTS_ERRORS=0

for file in AGENTS.md common/AGENTS.md; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓ $file exists${NC}"
    else
        echo -e "${RED}✗ $file must exist${NC}"
        AGENTS_ERRORS=$((AGENTS_ERRORS + 1))
    fi
done

if command_exists git && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    for file in AGENTS.md common/AGENTS.md; do
        if git check-ignore -q --no-index "$file"; then
            echo -e "${RED}✗ $file must not be ignored by Git${NC}"
            AGENTS_ERRORS=$((AGENTS_ERRORS + 1))
        else
            echo -e "${GREEN}✓ $file is not ignored by Git${NC}"
        fi

    done
else
    echo -e "${YELLOW}⚠ not inside a git work tree (or git not installed), skipping AGENTS Git checks${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

if grep -Fqx '    "AGENTS.md",' .dotstate-profiles.toml; then
    echo -e "${GREEN}✓ dotstate links common/AGENTS.md as ~/AGENTS.md${NC}"
else
    echo -e "${RED}✗ .dotstate-profiles.toml must list AGENTS.md as a common file${NC}"
    AGENTS_ERRORS=$((AGENTS_ERRORS + 1))
fi

if [ $AGENTS_ERRORS -gt 0 ]; then
    ERRORS=$((ERRORS + AGENTS_ERRORS))
fi
echo

# Test 11: Worktrunk workflow policy and configuration
echo -e "${BLUE}→ Checking Worktrunk workflow configuration...${NC}"
WORKTRUNK_ERRORS=0
WORKTRUNK_CONFIG="common/.config/worktrunk/config.toml"

if [ -f "$WORKTRUNK_CONFIG" ]; then
    echo -e "${GREEN}✓ Worktrunk user config exists${NC}"
else
    echo -e "${RED}✗ $WORKTRUNK_CONFIG must exist${NC}"
    WORKTRUNK_ERRORS=$((WORKTRUNK_ERRORS + 1))
fi

if command_exists git && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    if git check-ignore -q --no-index "$WORKTRUNK_CONFIG"; then
        echo -e "${RED}✗ Worktrunk user config must not be ignored by Git${NC}"
        WORKTRUNK_ERRORS=$((WORKTRUNK_ERRORS + 1))
    else
        echo -e "${GREEN}✓ Worktrunk user config is not ignored by Git${NC}"
    fi
fi

if grep -Fqx 'worktree-path = "~/worktrees/{{ repo }}/{{ branch | sanitize }}"' "$WORKTRUNK_CONFIG"; then
    echo -e "${GREEN}✓ Worktrunk uses the centralized repository/branch layout${NC}"
else
    echo -e "${RED}✗ Worktrunk path must be ~/worktrees/<repository>/<sanitized-branch>${NC}"
    WORKTRUNK_ERRORS=$((WORKTRUNK_ERRORS + 1))
fi

if command_exists wt; then
    if wt --config "$WORKTRUNK_CONFIG" config show >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Worktrunk accepts the managed user config${NC}"
    else
        echo -e "${RED}✗ Worktrunk rejected $WORKTRUNK_CONFIG${NC}"
        WORKTRUNK_ERRORS=$((WORKTRUNK_ERRORS + 1))
    fi
else
    echo -e "${YELLOW}⚠ wt not installed, skipping Worktrunk config validation${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

if grep -Fq 'ask the user to choose OpenSpec or no formal framework' common/AGENTS.md &&
   grep -Fq 'Do not select or initialize an SDD framework before the user chooses' common/AGENTS.md; then
    echo -e "${GREEN}✓ global instructions keep SDD framework selection with the user${NC}"
else
    echo -e "${RED}✗ SDD guidance must offer OpenSpec or no formal framework${NC}"
    WORKTRUNK_ERRORS=$((WORKTRUNK_ERRORS + 1))
fi

if grep -Fq 'Implement every medium-or-larger feature in a dedicated Worktrunk worktree' common/AGENTS.md &&
   grep -Fq 'wt switch --create <branch>' common/AGENTS.md &&
   grep -Fq 'do not silently fall back to raw git worktree commands' common/AGENTS.md; then
    echo -e "${GREEN}✓ global instructions require Worktrunk for medium-or-larger features${NC}"
else
    echo -e "${RED}✗ global instructions must require wt-managed medium feature worktrees${NC}"
    WORKTRUNK_ERRORS=$((WORKTRUNK_ERRORS + 1))
fi

if [ $WORKTRUNK_ERRORS -gt 0 ]; then
    ERRORS=$((ERRORS + WORKTRUNK_ERRORS))
fi
echo

# Test 12: dotstate manifest matches the repository layout
echo -e "${BLUE}→ Checking dotstate manifest...${NC}"
MANIFEST_ERRORS=0
MANIFEST=".dotstate-profiles.toml"

# Print "<dir> <path>" for every synced file, where <dir> is common or the
# profile name, i.e. the repository directory dotstate links it from
manifest_entries() {
    awk '
        /^\[common\]/ { dir = "common"; next }
        /^\[\[profiles\]\]/ { dir = ""; next }
        dir == "" && /^name = "/ { dir = $3; gsub(/"/, "", dir); next }
        /^synced_files = \[.*\]$/ {
            line = $0; sub(/^[^[]*\[/, "", line); sub(/\][[:space:]]*$/, "", line)
            n = split(line, items, ",")
            for (i = 1; i <= n; i++) { gsub(/[[:space:]"]/, "", items[i]); if (items[i] != "") print dir, items[i] }
            next
        }
        /^synced_files = \[/ { inside = 1; next }
        inside && /^\]/ { inside = 0; next }
        inside { gsub(/[[:space:]",]/, ""); if ($0 != "") print dir, $0 }
    ' "$MANIFEST"
}

if [ -f "$MANIFEST" ]; then
    MANIFEST_MISSING=0
    while read -r dir path; do
        if [ ! -e "$dir/$path" ] && [ ! -L "$dir/$path" ]; then
            echo -e "${RED}✗ $MANIFEST lists $path but $dir/$path does not exist${NC}"
            MANIFEST_MISSING=$((MANIFEST_MISSING + 1))
        fi
    done < <(manifest_entries)
    if [ "$MANIFEST_MISSING" -eq 0 ]; then
        echo -e "${GREEN}✓ every manifest entry exists in the repository${NC}"
    fi
    MANIFEST_ERRORS=$((MANIFEST_ERRORS + MANIFEST_MISSING))

    # Every tracked file under a profile directory must be covered by an
    # entry, or it would never be linked
    if command_exists git && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        MANIFEST_PATHS="$(manifest_entries | tr ' ' '/')"
        MANIFEST_UNLINKED=0
        while IFS= read -r file; do
            covered=false
            while IFS= read -r entry; do
                case "$file" in
                    "$entry"|"$entry"/*) covered=true; break ;;
                esac
            done <<< "$MANIFEST_PATHS"
            if [ "$covered" = false ]; then
                echo -e "${RED}✗ $file is tracked but not linked by $MANIFEST${NC}"
                MANIFEST_UNLINKED=$((MANIFEST_UNLINKED + 1))
            fi
        done < <(git ls-files common macos linux)
        if [ "$MANIFEST_UNLINKED" -eq 0 ]; then
            echo -e "${GREEN}✓ every tracked config file is linked by the manifest${NC}"
        fi
        MANIFEST_ERRORS=$((MANIFEST_ERRORS + MANIFEST_UNLINKED))
    fi
else
    echo -e "${RED}✗ $MANIFEST must exist${NC}"
    MANIFEST_ERRORS=$((MANIFEST_ERRORS + 1))
fi

if git check-ignore -q --no-index common/.pi/agent/settings.json; then
    echo -e "${RED}✗ common/.pi/agent/settings.json must remain trackable${NC}"
    MANIFEST_ERRORS=$((MANIFEST_ERRORS + 1))
else
    echo -e "${GREEN}✓ common/.pi/agent/settings.json is trackable${NC}"
fi

if git check-ignore -q --no-index common/.pi/agent/auth.json &&
   git check-ignore -q --no-index common/.pi/agent/npm/package.json; then
    echo -e "${GREEN}✓ pi credentials and packages are ignored${NC}"
else
    echo -e "${RED}✗ common/.pi/agent/auth.json and npm/ must be ignored${NC}"
    MANIFEST_ERRORS=$((MANIFEST_ERRORS + 1))
fi

if git check-ignore -q --no-index dots common/.local/bin/dots; then
    echo -e "${RED}✗ dots and common/.local/bin/dots must remain trackable${NC}"
    MANIFEST_ERRORS=$((MANIFEST_ERRORS + 1))
else
    echo -e "${GREEN}✓ the dots CLI and its link are trackable${NC}"
fi

if git check-ignore -q --no-index common/.agents/skills/paranoid-review/SKILL.md; then
    echo -e "${RED}✗ common/.agents/skills/paranoid-review/SKILL.md must remain trackable${NC}"
    MANIFEST_ERRORS=$((MANIFEST_ERRORS + 1))
else
    echo -e "${GREEN}✓ common/.agents/skills/paranoid-review/SKILL.md is trackable${NC}"
fi

if git check-ignore -q --no-index common/.agents/.skill-lock.json; then
    echo -e "${RED}✗ common/.agents/.skill-lock.json must remain trackable${NC}"
    MANIFEST_ERRORS=$((MANIFEST_ERRORS + 1))
else
    echo -e "${GREEN}✓ skills CLI lockfile under common/.agents is trackable${NC}"
fi

if git check-ignore -q --no-index common/.agents/skills-cli-cache/x; then
    echo -e "${GREEN}✓ skills CLI installs under common/.agents are ignored${NC}"
else
    echo -e "${RED}✗ only skills/ and .skill-lock.json may be tracked under common/.agents${NC}"
    MANIFEST_ERRORS=$((MANIFEST_ERRORS + 1))
fi

if git check-ignore -q --no-index common/.claude/settings.json ||
   git check-ignore -q --no-index common/.claude/themes/rose-pine.json; then
    echo -e "${RED}✗ common/.claude/settings.json and themes/ must remain trackable${NC}"
    MANIFEST_ERRORS=$((MANIFEST_ERRORS + 1))
else
    echo -e "${GREEN}✓ Claude Code settings and themes are trackable${NC}"
fi

if git check-ignore -q --no-index common/.claude/projects/x/session.jsonl &&
   git check-ignore -q --no-index common/.claude/settings.local.json &&
   git check-ignore -q --no-index common/.claude/.credentials.json; then
    echo -e "${GREEN}✓ Claude Code sessions, local settings and credentials are ignored${NC}"
else
    echo -e "${RED}✗ only settings.json and themes/ may be tracked under common/.claude${NC}"
    MANIFEST_ERRORS=$((MANIFEST_ERRORS + 1))
fi

if command_exists jq && [ -f common/.claude/settings.json ] &&
   jq -e 'has("autoMode") or has("permissions") or has("env") or has("apiKeyHelper") | not' \
       common/.claude/settings.json >/dev/null 2>&1; then
    echo -e "${GREEN}✓ tracked Claude Code settings hold no project, permission or credential keys${NC}"
elif ! command_exists jq; then
    echo -e "${YELLOW}⚠ jq not installed, skipping Claude Code settings key check${NC}"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${RED}✗ common/.claude/settings.json must be valid JSON without autoMode, permissions, env or apiKeyHelper${NC}"
    MANIFEST_ERRORS=$((MANIFEST_ERRORS + 1))
fi

if [ -L "common/.config/opencode/skills/paranoid-review" ] && [ -f "common/.config/opencode/skills/paranoid-review/SKILL.md" ]; then
    echo -e "${GREEN}✓ opencode paranoid-review skill links to the shared skill${NC}"
else
    echo -e "${RED}✗ common/.config/opencode/skills/paranoid-review must be a symlink to common/.agents/skills/paranoid-review${NC}"
    MANIFEST_ERRORS=$((MANIFEST_ERRORS + 1))
fi

if [ $MANIFEST_ERRORS -gt 0 ]; then
    ERRORS=$((ERRORS + MANIFEST_ERRORS))
fi
echo

# Test 13: link_dotfiles links each profile into a temp home with dotstate
echo -e "${BLUE}→ Checking link_dotfiles runs into temp homes...${NC}"
LINK_ERRORS=0
if command_exists dotstate; then
    LINK_REPO="$(pwd -P)"
    LINK_TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/dotstate-link-test.XXXXXX")"

    link_test13_prev_exit_trap="$(trap -p EXIT)"
    link_test13_prev_int_trap="$(trap -p INT)"
    link_test13_prev_term_trap="$(trap -p TERM)"
    link_test13_cleanup() {
        rm -rf "$LINK_TEST_ROOT"
    }
    trap link_test13_cleanup EXIT INT TERM

    # Runs the real link_dotfiles against an isolated HOME and this checkout.
    # $1=home dir, $2=OS (the profile written on first run), $3=log name
    link_run() {
        HOME="$1" bash -c \
            'source "$1"; DOTFILES="$2"; OS="$3"; link_dotfiles' \
            _ "$LINK_REPO/install.sh" "$LINK_REPO" "$2" \
            >"$1.$3.log" 2>&1
    }

    # Existing machine: unmanaged files at linked paths next to app state
    LINK_HOME="$LINK_TEST_ROOT/macos"
    mkdir -p "$LINK_HOME/.pi/agent" "$LINK_HOME/.agents/skills/other-skill" "$LINK_HOME/.claude/projects"
    printf '%s\n' 'unmanaged zshrc' > "$LINK_HOME/.zshrc"
    echo '{"unmanaged":true}' > "$LINK_HOME/.pi/agent/settings.json"
    echo '{"secret":"state"}' > "$LINK_HOME/.pi/agent/auth.json"
    echo '{"version":3}' > "$LINK_HOME/.agents/.skill-lock.json"
    echo 'existing' > "$LINK_HOME/.agents/skills/other-skill/SKILL.md"
    echo '{"unmanaged":"claude"}' > "$LINK_HOME/.claude/settings.json"
    echo 'session' > "$LINK_HOME/.claude/projects/session.jsonl"

    LINK_RESULT=0
    link_run "$LINK_HOME" macos run1 || LINK_RESULT=$?
    LINK_BACKUP="$(find "$LINK_HOME/.dotstate-backups" -mindepth 1 -maxdepth 1 -type d -print -quit 2>/dev/null || true)"

    if [ "$LINK_RESULT" -eq 0 ] &&
       [ "$(readlink "$LINK_HOME/.zshrc")" = "$LINK_REPO/common/.zshrc" ] &&
       [ "$(readlink "$LINK_HOME/AGENTS.md")" = "$LINK_REPO/common/AGENTS.md" ] &&
       [ "$(readlink "$LINK_HOME/.config/kitty")" = "$LINK_REPO/macos/.config/kitty" ] &&
       [ -n "$LINK_BACKUP" ] &&
       grep -qx 'unmanaged zshrc' "$LINK_BACKUP/.zshrc" &&
       grep -q '"unmanaged"' "$LINK_BACKUP/.pi/agent/settings.json" &&
       grep -q '"version":3' "$LINK_BACKUP/.agents/.skill-lock.json" &&
       grep -q '"claude"' "$LINK_BACKUP/.claude/settings.json"; then
        echo -e "${GREEN}✓ macos profile links common and macOS configs and backs up conflicting files${NC}"
    else
        echo -e "${RED}✗ link_dotfiles must link the macos profile and back up conflicting files (exit $LINK_RESULT)${NC}"
        cat "$LINK_HOME.run1.log"
        LINK_ERRORS=$((LINK_ERRORS + 1))
    fi

    if [ -d "$LINK_HOME/.pi/agent" ] && [ ! -L "$LINK_HOME/.pi/agent" ] &&
       [ -L "$LINK_HOME/.pi/agent/settings.json" ] &&
       grep -q '"secret"' "$LINK_HOME/.pi/agent/auth.json" &&
       [ -d "$LINK_HOME/.agents/skills" ] && [ ! -L "$LINK_HOME/.agents/skills" ] &&
       [ -L "$LINK_HOME/.agents/skills/paranoid-review" ] &&
       [ "$(cat "$LINK_HOME/.agents/skills/other-skill/SKILL.md")" = "existing" ] &&
       [ "$(readlink "$LINK_HOME/.agents/.skill-lock.json")" = "$LINK_REPO/common/.agents/.skill-lock.json" ] &&
       [ -d "$LINK_HOME/.claude" ] && [ ! -L "$LINK_HOME/.claude" ] &&
       [ "$(readlink "$LINK_HOME/.claude/settings.json")" = "$LINK_REPO/common/.claude/settings.json" ] &&
       [ "$(readlink "$LINK_HOME/.claude/themes")" = "$LINK_REPO/common/.claude/themes" ] &&
       [ "$(cat "$LINK_HOME/.claude/projects/session.jsonl")" = "session" ]; then
        echo -e "${GREEN}✓ ~/.pi/agent, ~/.agents and ~/.claude stay real directories with their state untouched${NC}"
    else
        echo -e "${RED}✗ only tracked settings, themes, the skills lockfile and paranoid-review may be linked inside ~/.pi/agent, ~/.agents and ~/.claude${NC}"
        LINK_ERRORS=$((LINK_ERRORS + 1))
    fi

    LINK_BACKUPS_BEFORE="$(find "$LINK_HOME/.dotstate-backups" -mindepth 1 -maxdepth 1 | wc -l)"
    LINK_RESULT=0
    link_run "$LINK_HOME" macos run2 || LINK_RESULT=$?
    LINK_BACKUPS_AFTER="$(find "$LINK_HOME/.dotstate-backups" -mindepth 1 -maxdepth 1 | wc -l)"
    if [ "$LINK_RESULT" -eq 0 ] && [ "$LINK_BACKUPS_BEFORE" -eq "$LINK_BACKUPS_AFTER" ]; then
        echo -e "${GREEN}✓ a second link_dotfiles run is a no-op${NC}"
    else
        echo -e "${RED}✗ re-running link_dotfiles must succeed without new backups (exit $LINK_RESULT)${NC}"
        cat "$LINK_HOME.run2.log"
        LINK_ERRORS=$((LINK_ERRORS + 1))
    fi

    # Fresh Linux machine: common files only
    LINK_LINUX_HOME="$LINK_TEST_ROOT/linux"
    mkdir -p "$LINK_LINUX_HOME"
    LINK_RESULT=0
    link_run "$LINK_LINUX_HOME" linux run1 || LINK_RESULT=$?
    if [ "$LINK_RESULT" -eq 0 ] &&
       [ "$(readlink "$LINK_LINUX_HOME/.zshrc")" = "$LINK_REPO/common/.zshrc" ] &&
       [ ! -e "$LINK_LINUX_HOME/.config/kitty" ] &&
       [ ! -e "$LINK_LINUX_HOME/.config/aerospace" ]; then
        echo -e "${GREEN}✓ linux profile links common configs only${NC}"
    else
        echo -e "${RED}✗ link_dotfiles must link only common configs for the linux profile (exit $LINK_RESULT)${NC}"
        cat "$LINK_LINUX_HOME.run1.log"
        LINK_ERRORS=$((LINK_ERRORS + 1))
    fi

    # Existing machine pulling a new layout: a clone of this checkout with a
    # manifest entry added after the first link
    LINK_CLONE="$LINK_TEST_ROOT/repo"
    LINK_PULL_HOME="$LINK_TEST_ROOT/pull"
    mkdir -p "$LINK_PULL_HOME"
    git clone -q "$LINK_REPO" "$LINK_CLONE"
    git -C "$LINK_CLONE" checkout -q "$(git rev-parse HEAD)"
    cp install.sh "$LINK_CLONE/install.sh"

    LINK_RESULT=0
    LINK_REPO="$LINK_CLONE" link_run "$LINK_PULL_HOME" linux run1 || LINK_RESULT=$?
    if [ "$LINK_RESULT" -ne 0 ]; then
        echo -e "${RED}✗ link_dotfiles must link a clone of this checkout (exit $LINK_RESULT)${NC}"
        cat "$LINK_PULL_HOME.run1.log"
        LINK_ERRORS=$((LINK_ERRORS + 1))
    fi

    mkdir -p "$LINK_CLONE/common/.config/newtool"
    echo 'new' > "$LINK_CLONE/common/.config/newtool/config"
    awk '{ print } /^    "\.config\/zsh",$/ { print "    \".config/newtool\"," }' \
        "$LINK_CLONE/.dotstate-profiles.toml" > "$LINK_CLONE/manifest.new"
    mv "$LINK_CLONE/manifest.new" "$LINK_CLONE/.dotstate-profiles.toml"
    LINK_RESULT=0
    LINK_REPO="$LINK_CLONE" link_run "$LINK_PULL_HOME" linux run2 || LINK_RESULT=$?
    if [ "$LINK_RESULT" -eq 0 ] &&
       [ "$(readlink "$LINK_PULL_HOME/.config/newtool")" = "$LINK_CLONE/common/.config/newtool" ] &&
       ! grep -q 'still reports errors' "$LINK_PULL_HOME.run2.log"; then
        echo -e "${GREEN}✓ re-running link_dotfiles links paths added to the manifest${NC}"
    else
        echo -e "${RED}✗ link_dotfiles must link a newly added manifest entry on re-run (exit $LINK_RESULT)${NC}"
        cat "$LINK_PULL_HOME.run2.log"
        LINK_ERRORS=$((LINK_ERRORS + 1))
    fi

    link_test13_cleanup
    eval "${link_test13_prev_exit_trap:-trap - EXIT}"
    eval "${link_test13_prev_int_trap:-trap - INT}"
    eval "${link_test13_prev_term_trap:-trap - TERM}"
    unset -f link_test13_cleanup link_run
else
    echo -e "${YELLOW}⚠ dotstate not installed, skipping link_dotfiles check${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

if [ $LINK_ERRORS -gt 0 ]; then
    ERRORS=$((ERRORS + LINK_ERRORS))
fi
echo

# Test 14: install_agent_skills restores missing skills from the lockfile
echo -e "${BLUE}→ Checking agent skill installation...${NC}"
SKILLS_ERRORS=0

if step_runs_before link_dotfiles install_agent_skills; then
    echo -e "${GREEN}✓ agent skills install after dotfiles are linked${NC}"
else
    echo -e "${RED}✗ install_agent_skills must run after link_dotfiles in a full install${NC}"
    SKILLS_ERRORS=$((SKILLS_ERRORS + 1))
fi

if command_exists jq; then
    SKILLS_TEST_DIR="$(mktemp -d "${TMPDIR:-/tmp}/agent-skills-test.XXXXXX")"
    SKILLS_JQ_DIR="$(dirname "$(command -v jq)")"

    skills_test14_prev_exit_trap="$(trap -p EXIT)"
    skills_test14_prev_int_trap="$(trap -p INT)"
    skills_test14_prev_term_trap="$(trap -p TERM)"
    skills_test14_cleanup() {
        rm -rf "$SKILLS_TEST_DIR"
    }
    trap skills_test14_cleanup EXIT INT TERM

    # Stub npx: logs every invocation ("$*") and fails for one scripted source,
    # so tests never reach the network or the real skills directory
    mkdir -p "$SKILLS_TEST_DIR/bin"
    cat > "$SKILLS_TEST_DIR/bin/npx" <<'STUB'
#!/usr/bin/env bash
echo "$*" >> "$SKILLS_STUB_LOG"
case "$*" in
    *"${SKILLS_STUB_FAIL:-<none>}"*) exit 1 ;;
esac
STUB
    chmod +x "$SKILLS_TEST_DIR/bin/npx"

    # $1=lockfile JSON, $2=source to fail (or ""), $3=CI value, $4=skill to
    # leave as a real directory in ~/.claude/skills, $5=skill to leave as a
    # dangling link there
    run_skills_scenario() {
        local home="$SKILLS_TEST_DIR/home"
        rm -rf "$home"
        mkdir -p "$home/.agents/skills/installed" "$home/.claude/skills"
        printf '%s' "$1" > "$home/.agents/.skill-lock.json"
        [ -z "${4:-}" ] || { mkdir -p "$home/.claude/skills/$4"; echo 'local' > "$home/.claude/skills/$4/SKILL.md"; }
        [ -z "${5:-}" ] || ln -s "../../.agents/skills/$5" "$home/.claude/skills/$5"
        : > "$SKILLS_TEST_DIR/log"
        local ci=(-u CI)
        [ -z "${3:-}" ] || ci=("CI=$3")
        # Only the npx stub, jq and the base system tools are reachable
        env -u CLAUDE_CONFIG_DIR "${ci[@]}" HOME="$home" PATH="$SKILLS_TEST_DIR/bin:$SKILLS_JQ_DIR:/usr/bin:/bin" \
            SKILLS_STUB_LOG="$SKILLS_TEST_DIR/log" SKILLS_STUB_FAIL="$2" \
            bash -c 'source ./install.sh; install_agent_skills' >/dev/null 2>&1
    }

    SKILLS_LOCK='{"version":3,"skills":{
        "installed":{"sourceUrl":"https://github.com/a/one.git"},
        "alpha":{"sourceUrl":"https://github.com/a/one.git"},
        "beta":{"sourceUrl":"https://github.com/a/one.git"},
        "gamma":{"sourceUrl":"https://github.com/b/two.git"}}}'

    if run_skills_scenario "$SKILLS_LOCK" "" "" &&
       [ "$(wc -l < "$SKILLS_TEST_DIR/log")" -eq 2 ] &&
       grep -qx -- '-y skills add https://github.com/a/one.git --global --agent claude-code --yes --skill alpha beta' "$SKILLS_TEST_DIR/log" &&
       grep -qx -- '-y skills add https://github.com/b/two.git --global --agent claude-code --yes --skill gamma' "$SKILLS_TEST_DIR/log"; then
        echo -e "${GREEN}✓ missing skills install once per source and installed ones are skipped${NC}"
    else
        echo -e "${RED}✗ install_agent_skills must run one skills add per source for missing skills only${NC}"
        cat "$SKILLS_TEST_DIR/log"
        SKILLS_ERRORS=$((SKILLS_ERRORS + 1))
    fi

    if ! run_skills_scenario "$SKILLS_LOCK" "b/two" "" &&
       grep -q 'a/one' "$SKILLS_TEST_DIR/log"; then
        echo -e "${GREEN}✓ a failed source fails the step without stopping other sources${NC}"
    else
        echo -e "${RED}✗ install_agent_skills must try every source and fail when one does${NC}"
        SKILLS_ERRORS=$((SKILLS_ERRORS + 1))
    fi

    if ! run_skills_scenario '{"version":3,"skills":{"../escape":{"sourceUrl":"https://github.com/a/one.git"}}}' "" "" &&
       [ ! -s "$SKILLS_TEST_DIR/log" ]; then
        echo -e "${GREEN}✓ skill names that are not plain directory names are rejected${NC}"
    else
        echo -e "${RED}✗ install_agent_skills must reject skill names containing / or starting with .${NC}"
        SKILLS_ERRORS=$((SKILLS_ERRORS + 1))
    fi

    if run_skills_scenario "$SKILLS_LOCK" "" "" "alpha" "gamma" &&
       grep -qx -- '-y skills add https://github.com/a/one.git --global --agent claude-code --yes --skill beta' "$SKILLS_TEST_DIR/log" &&
       grep -q -- '--skill gamma$' "$SKILLS_TEST_DIR/log" &&
       [ "$(cat "$SKILLS_TEST_DIR/home/.claude/skills/alpha/SKILL.md")" = "local" ]; then
        echo -e "${GREEN}✓ real directories in ~/.claude/skills are never handed to the skills CLI${NC}"
    else
        echo -e "${RED}✗ install_agent_skills must skip skills whose ~/.claude/skills path is a real directory${NC}"
        cat "$SKILLS_TEST_DIR/log"
        SKILLS_ERRORS=$((SKILLS_ERRORS + 1))
    fi

    if ! run_skills_scenario 'not json' "" "" && [ ! -s "$SKILLS_TEST_DIR/log" ] &&
       ! run_skills_scenario '{"version":3,"skills":{"alpha":{"sourceUrl":1}}}' "" "" && [ ! -s "$SKILLS_TEST_DIR/log" ] &&
       ! run_skills_scenario '{"version":3}' "" "" && [ ! -s "$SKILLS_TEST_DIR/log" ]; then
        echo -e "${GREEN}✓ a malformed lockfile fails without installing anything${NC}"
    else
        echo -e "${RED}✗ install_agent_skills must fail on malformed JSON, a missing skills object or a non-string sourceUrl${NC}"
        SKILLS_ERRORS=$((SKILLS_ERRORS + 1))
    fi

    if run_skills_scenario '{"version":3,"skills":{}}' "" "" && [ ! -s "$SKILLS_TEST_DIR/log" ]; then
        echo -e "${GREEN}✓ an empty skill inventory succeeds without installing anything${NC}"
    else
        echo -e "${RED}✗ install_agent_skills must accept a lockfile with no skills${NC}"
        SKILLS_ERRORS=$((SKILLS_ERRORS + 1))
    fi

    if run_skills_scenario "$SKILLS_LOCK" "" "true" && [ ! -s "$SKILLS_TEST_DIR/log" ]; then
        echo -e "${GREEN}✓ agent skill installation is skipped in CI${NC}"
    else
        echo -e "${RED}✗ install_agent_skills must skip in CI${NC}"
        SKILLS_ERRORS=$((SKILLS_ERRORS + 1))
    fi

    skills_test14_cleanup
    eval "${skills_test14_prev_exit_trap:-trap - EXIT}"
    eval "${skills_test14_prev_int_trap:-trap - INT}"
    eval "${skills_test14_prev_term_trap:-trap - TERM}"
    unset -f skills_test14_cleanup run_skills_scenario
else
    echo -e "${YELLOW}⚠ jq not installed, skipping agent skill installation check${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

if [ $SKILLS_ERRORS -gt 0 ]; then
    ERRORS=$((ERRORS + SKILLS_ERRORS))
fi
echo

# Test 15: install_ccstatusline installs the status line command once
echo -e "${BLUE}→ Checking ccstatusline installation...${NC}"
CCSTATUS_ERRORS=0
CCSTATUS_TEST_DIR="$(mktemp -d "${TMPDIR:-/tmp}/ccstatusline-test.XXXXXX")"
mkdir -p "$CCSTATUS_TEST_DIR/bin"
cat > "$CCSTATUS_TEST_DIR/bin/npm" <<'STUB'
#!/usr/bin/env bash
echo "$*" >> "$CCSTATUS_STUB_LOG"
STUB
chmod +x "$CCSTATUS_TEST_DIR/bin/npm"

# $1=extra stub to put on PATH (ccstatusline or "")
run_ccstatus_scenario() {
    : > "$CCSTATUS_TEST_DIR/log"
    rm -f "$CCSTATUS_TEST_DIR/bin/ccstatusline"
    [ -z "$1" ] || { printf '#!/bin/sh\n' > "$CCSTATUS_TEST_DIR/bin/$1"; chmod +x "$CCSTATUS_TEST_DIR/bin/$1"; }
    env PATH="$CCSTATUS_TEST_DIR/bin:/usr/bin:/bin" CCSTATUS_STUB_LOG="$CCSTATUS_TEST_DIR/log" \
        bash -c 'source ./install.sh; install_ccstatusline' >/dev/null 2>&1
}

if run_ccstatus_scenario "" && grep -qx 'install --global ccstatusline' "$CCSTATUS_TEST_DIR/log" &&
   run_ccstatus_scenario ccstatusline && [ ! -s "$CCSTATUS_TEST_DIR/log" ]; then
    echo -e "${GREEN}✓ ccstatusline installs with npm only when missing${NC}"
else
    echo -e "${RED}✗ install_ccstatusline must run npm install --global ccstatusline only when it is missing${NC}"
    CCSTATUS_ERRORS=$((CCSTATUS_ERRORS + 1))
fi

if step_runs_before install_brew_packages install_ccstatusline; then
    echo -e "${GREEN}✓ ccstatusline installs after the Brewfile provides node${NC}"
else
    echo -e "${RED}✗ install_ccstatusline must run after install_brew_packages in a full install${NC}"
    CCSTATUS_ERRORS=$((CCSTATUS_ERRORS + 1))
fi

rm -rf "$CCSTATUS_TEST_DIR"
unset -f run_ccstatus_scenario
if [ $CCSTATUS_ERRORS -gt 0 ]; then
    ERRORS=$((ERRORS + CCSTATUS_ERRORS))
fi
echo

# Test 16: the dots CLI installs components selectively
echo -e "${BLUE}→ Checking the dots CLI...${NC}"
DOTS_ERRORS=0

# The full install runs exactly these steps in this order
DOTS_EXPECTED_STEPS="install_linux_homebrew_dependencies
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
install_ccstatusline
install_dotstate
link_dotfiles
install_herdr_plugins
install_agent_skills"
if [ "$INSTALL_STEP_ORDER" = "$DOTS_EXPECTED_STEPS" ]; then
    echo -e "${GREEN}✓ a full install runs every step in the expected order${NC}"
else
    echo -e "${RED}✗ main must run every install step once, in the expected order:${NC}"
    echo "$INSTALL_STEP_ORDER"
    DOTS_ERRORS=$((DOTS_ERRORS + 1))
fi
DOTS_TEST_DIR="$(mktemp -d "${TMPDIR:-/tmp}/dots-test.XXXXXX")"
mkdir -p "$DOTS_TEST_DIR/bin" "$DOTS_TEST_DIR/home/.local/bin"
cat > "$DOTS_TEST_DIR/bin/dotstate" <<'STUB'
#!/usr/bin/env bash
echo "dotstate $*" >> "$DOTS_STUB_LOG"
STUB
chmod +x "$DOTS_TEST_DIR/bin/dotstate"

# Runs dots_main with stubbed components that log instead of installing, no
# Homebrew and only the stubs on PATH. Args are passed to dots_main; set
# DOTS_SKIP_REQUIRES=1 to stub the prerequisite checks too.
run_dots() {
    : > "$DOTS_TEST_DIR/log"
    # shellcheck disable=SC2016
    env HOME="$DOTS_TEST_DIR/home" PATH="$DOTS_TEST_DIR/bin:/usr/bin:/bin" \
        DOTS_STUB_LOG="$DOTS_TEST_DIR/log" DOTS_SKIP_REQUIRES="${DOTS_SKIP_REQUIRES:-}" bash -c '
        source ./dots
        load_brew_env() { :; }
        [ -z "$DOTS_SKIP_REQUIRES" ] || component_requires() { :; }
        for component in "${COMPONENTS[@]}"; do
            eval "component_$component() { echo $component >> \"\$DOTS_STUB_LOG\"; }"
        done
        dots_main "$@"' _ "$@" >"$DOTS_TEST_DIR/out" 2>&1
}

DOTS_COMPONENTS="$(bash -c 'source ./install.sh; printf "%s\n" "${COMPONENTS[@]}"')"
ln -s "$(pwd)/common/.local/bin/dots" "$DOTS_TEST_DIR/home/.local/bin/dots"
if [ "$("$DOTS_TEST_DIR/home/.local/bin/dots" list | awk '{ print $1 }')" = "$DOTS_COMPONENTS" ]; then
    echo -e "${GREEN}✓ dots list shows every component through the linked command${NC}"
else
    echo -e "${RED}✗ dots list, run through ~/.local/bin/dots, must print every component in order${NC}"
    DOTS_ERRORS=$((DOTS_ERRORS + 1))
fi

# Neither Homebrew nor npx is on the stub PATH
if ! run_dots install skills && [ ! -s "$DOTS_TEST_DIR/log" ] &&
   grep -q 'npx not found; run: dots install brew' "$DOTS_TEST_DIR/out"; then
    echo -e "${GREEN}✓ dots install fails with a hint when a component's prerequisites are missing${NC}"
else
    echo -e "${RED}✗ dots install skills without npx must stop with a 'run: dots install brew' hint before running anything${NC}"
    cat "$DOTS_TEST_DIR/out"
    DOTS_ERRORS=$((DOTS_ERRORS + 1))
fi

if DOTS_SKIP_REQUIRES=1 run_dots install skills tools shell skills &&
   [ "$(cat "$DOTS_TEST_DIR/log")" = "$(printf '%s\n' shell tools skills)" ]; then
    echo -e "${GREEN}✓ dots install runs the selected components once each in install order${NC}"
else
    echo -e "${RED}✗ dots install skills tools shell skills must run shell, tools, skills once each${NC}"
    cat "$DOTS_TEST_DIR/out"
    DOTS_ERRORS=$((DOTS_ERRORS + 1))
fi

if ! run_dots install brew nope && [ ! -s "$DOTS_TEST_DIR/log" ] &&
   grep -q 'Unknown component: nope' "$DOTS_TEST_DIR/out" &&
   ! run_dots install; then
    echo -e "${GREEN}✓ dots install rejects unknown or missing components without installing anything${NC}"
else
    echo -e "${RED}✗ dots install must reject unknown components and an empty selection${NC}"
   ! run_dots install 'brew gh' && [ ! -s "$DOTS_TEST_DIR/log" ] &&
    DOTS_ERRORS=$((DOTS_ERRORS + 1))
fi

if run_dots doctor --fix && [ "$(cat "$DOTS_TEST_DIR/log")" = "dotstate doctor --fix" ] &&
   run_dots sync -m "Update foo" && [ "$(cat "$DOTS_TEST_DIR/log")" = "dotstate sync -m Update foo" ]; then
    echo -e "${GREEN}✓ dots passes dotstate commands through with their arguments${NC}"
else
    echo -e "${RED}✗ dots doctor/sync must run dotstate with the same arguments${NC}"
    cat "$DOTS_TEST_DIR/out"
    DOTS_ERRORS=$((DOTS_ERRORS + 1))
fi

rm -rf "$DOTS_TEST_DIR"
unset -f run_dots
if [ $DOTS_ERRORS -gt 0 ]; then
    ERRORS=$((ERRORS + DOTS_ERRORS))
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
