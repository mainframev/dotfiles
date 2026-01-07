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
    if [ -f ".config/install.sh" ]; then
        if shellcheck .config/install.sh; then
            echo -e "${GREEN}✓ .config/install.sh passed shellcheck${NC}"
        else
            echo -e "${RED}✗ .config/install.sh has shellcheck issues${NC}"
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

# Test 6: YAML configuration (GitHub workflows)
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
