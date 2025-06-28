#!/bin/bash

# Setup git hooks for lastplace.nvim

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🔧 Setting up git hooks...${NC}"

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "Error: Not in a git repository"
    exit 1
fi

# Create .githooks directory if it doesn't exist
mkdir -p .githooks

# Copy hooks to git hooks directory
hooks_dir=".git/hooks"

# Function to setup a hook
setup_hook() {
    local hook_name="$1"
    local source_file=".githooks/$hook_name"
    local target_file="$hooks_dir/$hook_name"
    
    if [ -f "$source_file" ]; then
        echo -e "${YELLOW}📋 Setting up $hook_name hook...${NC}"
        cp "$source_file" "$target_file"
        chmod +x "$target_file"
        echo -e "${GREEN}✅ $hook_name hook installed${NC}"
    else
        echo -e "${YELLOW}⚠️  $source_file not found, skipping${NC}"
    fi
}

# Setup all hooks
setup_hook "pre-commit"
setup_hook "pre-push" 
setup_hook "commit-msg"

echo ""
echo -e "${GREEN}🎉 Git hooks setup complete!${NC}"
echo ""
echo -e "${CYAN}What the hooks do:${NC}"
echo "  pre-commit:  Format code, run lint"
echo "  commit-msg:  Validate commit message format"
echo ""
echo -e "${YELLOW}💡 Tips:${NC}"
echo "  Skip hooks:     git commit --no-verify"
echo "  Test hooks:     make check"
echo "  Update hooks:   ./scripts/setup-hooks.sh"
