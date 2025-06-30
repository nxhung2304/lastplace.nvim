.PHONY: lint lint-fix format clean help hooks hooks-remove

# Colors for output
CYAN := \033[36m
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m
RESET := \033[0m

# Directories
LUA_DIR := lua

lint: ## Run linting with luacheck
	@echo "$(GREEN)[INFO]$(RESET) Running luacheck..."
	@if command -v luacheck >/dev/null 2>&1; then \
		if luacheck $(LUA_DIR)/; then \
			echo "$(GREEN)[SUCCESS]$(RESET) Linting passed!"; \
		else \
			echo "$(RED)[ERROR]$(RESET) Linting failed!"; \
			exit 1; \
		fi; \
	else \
		echo "$(YELLOW)[WARN]$(RESET) luacheck not found."; \
		echo "$(YELLOW)[INSTALL]$(RESET) Install with: sudo luarocks install luacheck"; \
		echo "$(YELLOW)[INSTALL]$(RESET) Or: sudo apt-get install luacheck"; \
	fi

lint-fix: ## Fix linting issues automatically
	@echo "$(GREEN)[INFO]$(RESET) Auto-fixing linting issues..."
	@if command -v luacheck >/dev/null 2>&1; then \
		luacheck $(LUA_DIR)/ --no-unused-args --no-unused --globals vim; \
		echo "$(GREEN)[SUCCESS]$(RESET) Linting auto-fix completed!"; \
	else \
		echo "$(YELLOW)[WARN]$(RESET) luacheck not found."; \
		echo "$(YELLOW)[INSTALL]$(RESET) Install with: sudo luarocks install luacheck"; \
	fi

format: ## Format code with stylua
	@echo "$(GREEN)[INFO]$(RESET) Formatting code with stylua..."
	@if command -v stylua >/dev/null 2>&1; then \
		cd $(shell pwd) && stylua lua/; \
		echo "$(GREEN)[SUCCESS]$(RESET) Code formatted!"; \
	else \
		echo "$(YELLOW)[WARN]$(RESET) stylua not found."; \
		echo "$(YELLOW)[INSTALL]$(RESET) Install from: https://github.com/JohnnyMorganz/StyLua"; \
	fi

hooks: ## Setup git hooks for code quality
	@echo "$(GREEN)[INFO]$(RESET) Setting up git hooks..."
	@if [ ! -d ".git" ]; then \
		echo "$(RED)[ERROR]$(RESET) Not in a git repository"; \
		exit 1; \
	fi
	@chmod +x scripts/setup-hooks.sh
	@./scripts/setup-hooks.sh
	@echo "$(GREEN)[SUCCESS]$(RESET) Git hooks installed!"

hooks-remove: ## Remove git hooks
	@echo "$(GREEN)[INFO]$(RESET) Removing git hooks..."
	@rm -f .git/hooks/pre-commit .git/hooks/commit-msg
	@echo "$(GREEN)[SUCCESS]$(RESET) Git hooks removed!"

help: ## Show this help message
	@echo "$(CYAN)LastPlace.nvim Development Commands:$(RESET)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(CYAN)%-15s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "  make hooks    # Setup git hooks"
