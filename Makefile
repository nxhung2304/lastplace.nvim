.PHONY: lint format install clean help dev watch check docs release

# Colors for output
CYAN := \033[36m
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m
RESET := \033[0m

# Directories
LUA_DIR := lua

install: ## Install development dependencies
	@echo "$(GREEN)[INFO]$(RESET) Installing plenary.nvim..."
	@mkdir -p ~/.local/share/nvim/site/pack/testing/start/
	@if [ ! -d "$(PLENARY_DIR)" ]; then \
		git clone --depth=1 https://github.com/nvim-lua/plenary.nvim.git "$(PLENARY_DIR)"; \
		echo "$(GREEN)[INFO]$(RESET) Plenary.nvim installed successfully!"; \
	else \
		echo "$(YELLOW)[INFO]$(RESET) Plenary.nvim already installed."; \
	fi


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

format: ## Format code with stylua
	@echo "$(GREEN)[INFO]$(RESET) Formatting code with stylua..."
	@if command -v stylua >/dev/null 2>&1; then \
		stylua $(LUA_DIR)/ $(TEST_DIR)/; \
		echo "$(GREEN)[SUCCESS]$(RESET) Code formatted!"; \
	else \
		echo "$(YELLOW)[WARN]$(RESET) stylua not found."; \
		echo "$(YELLOW)[INSTALL]$(RESET) Install from: https://github.com/JohnnyMorganz/StyLua"; \
	fi

format-check: ## Check code formatting
	@echo "$(GREEN)[INFO]$(RESET) Checking code formatting..."
	@if command -v stylua >/dev/null 2>&1; then \
		if stylua --check $(LUA_DIR)/ $(TEST_DIR)/; then \
			echo "$(GREEN)[SUCCESS]$(RESET) Code formatting is correct!"; \
		else \
			echo "$(RED)[ERROR]$(RESET) Code formatting issues found!"; \
			echo "$(YELLOW)[FIX]$(RESET) Run: make format"; \
			exit 1; \
		fi; \
	else \
		echo "$(YELLOW)[WARN]$(RESET) stylua not found. Skipping format check."; \
	fi

clean: ## Clean temporary files and caches
	@echo "$(GREEN)[INFO]$(RESET) Cleaning temporary files..."
	@rm -rf .coverage/
	@rm -f coverage.out
	@find . -name "*.tmp" -delete 2>/dev/null || true
	@find . -name "*.swp" -delete 2>/dev/null || true
	@find . -name "*.swo" -delete 2>/dev/null || true
	@echo "$(GREEN)[SUCCESS]$(RESET) Clean complete!"

clean-all: clean ## Clean everything including dependencies
	@echo "$(GREEN)[INFO]$(RESET) Cleaning all dependencies..."
	@rm -rf "$(PLENARY_DIR)"
	@echo "$(GREEN)[SUCCESS]$(RESET) All dependencies cleaned!"

dev: install ## Start development environment with tmux
	@echo "$(GREEN)[INFO]$(RESET) Starting development environment..."
	@if command -v tmux >/dev/null 2>&1; then \
		tmux has-session -t lastplace_dev 2>/dev/null && tmux kill-session -t lastplace_dev; \
		tmux new-session -d -s lastplace_dev -c "$(PWD)" 'nvim .'; \
		tmux split-window -t lastplace_dev -h -c "$(PWD)"; \
		tmux send-keys -t lastplace_dev:0.1 'make watch' Enter; \
		tmux select-pane -t lastplace_dev:0.0; \
		echo "$(GREEN)[SUCCESS]$(RESET) Development session started!"; \
		echo "$(YELLOW)[INFO]$(RESET) Attaching to tmux session 'lastplace_dev'..."; \
		tmux attach -t lastplace_dev; \
	else \
		echo "$(YELLOW)[WARN]$(RESET) tmux not found. Opening nvim directly..."; \
		nvim .; \
	fi

dev-simple: ## Start simple development (just nvim)
	@echo "$(GREEN)[INFO]$(RESET) Starting simple development environment..."
	@nvim .

check: format-check lint ## Run all checks (format + lint)
	@echo "$(GREEN)[SUCCESS]$(RESET) All checks passed! 🎉"

docs: ## Show documentation info
	@echo "$(GREEN)[INFO]$(RESET) Documentation locations:"
	@echo "  📖 Help file: doc/lastplace.txt"
	@echo "  📚 README: README.md"
	@echo "  🤝 Contributing: CONTRIBUTING.md"
	@echo ""
	@echo "$(YELLOW)[VIEW]$(RESET) To view help in Neovim:"
	@echo "  nvim -c 'help lastplace'"

validate: ## Validate plugin structure
	@echo "$(GREEN)[INFO]$(RESET) Validating plugin structure..."
	@error_count=0; \
	for file in lua/lastplace/init.lua lua/lastplace/config.lua lua/lastplace/core.lua; do \
		if [ ! -f "$$file" ]; then \
			echo "$(RED)[ERROR]$(RESET) Missing required file: $$file"; \
			error_count=$$((error_count + 1)); \
		fi; \
	done; \
	for file in README.md LICENSE CONTRIBUTING.md; do \
		if [ ! -f "$$file" ]; then \
			echo "$(RED)[ERROR]$(RESET) Missing required file: $$file"; \
			error_count=$$((error_count + 1)); \
		fi; \
	done; \
	if [ $$error_count -eq 0 ]; then \
		echo "$(GREEN)[SUCCESS]$(RESET) Plugin structure is valid!"; \
	else \
		echo "$(RED)[ERROR]$(RESET) Found $$error_count issues"; \
		exit 1; \
	fi

release: check validate ## Prepare for release (run all checks + validation)
	@echo "$(GREEN)[SUCCESS]$(RESET) Release preparation complete! 🚀"
	@echo "$(YELLOW)[NEXT]$(RESET) Ready to tag and release."
	@echo ""
	@echo "$(CYAN)Release checklist:$(RESET)"
	@echo "  ✅ Code formatting correct"
	@echo "  ✅ Linting passed"
	@echo "  ✅ Plugin structure valid"
	@echo ""
	@echo "$(YELLOW)[MANUAL STEPS]$(RESET)"
	@echo "  1. Update CHANGELOG.md"
	@echo "  2. Update version in README.md"
	@echo "  3. Git tag: git tag -a v1.0.0 -m 'Release v1.0.0'"
	@echo "  4. Push: git push origin v1.0.0"

status: ## Show development status
	@echo "$(CYAN)lastplace.nvim Development Status$(RESET)"
	@echo ""
	@echo "$(GREEN)Dependencies:$(RESET)"
	@if [ -d "$(PLENARY_DIR)" ]; then \
		echo "  ✅ plenary.nvim installed"; \
	else \
		echo "  ❌ plenary.nvim missing (run: make install)"; \
	fi
	@if command -v stylua >/dev/null 2>&1; then \
		echo "  ✅ stylua available"; \
	else \
		echo "  ❌ stylua missing (optional)"; \
	fi
	@if command -v luacheck >/dev/null 2>&1; then \
		echo "  ✅ luacheck available"; \
	else \
		echo "  ❌ luacheck missing (optional)"; \
	fi
	@echo ""
	@echo "$(GREEN)Project Files:$(RESET)"
	@for file in lua/lastplace/init.lua README.md LICENSE; do \
		if [ -f "$$file" ]; then \
			echo "  ✅ $$file"; \
		else \
			echo "  ❌ $$file"; \
		fi; \
	done
	@echo ""
	@echo "$(GREEN)Quick Commands:$(RESET)"
	@echo "  make dev     # Start development"
	@echo "  make check   # Run all checks"

hooks: ## Setup git hooks for code quality
	@echo "$(GREEN)[INFO]$(RESET) Setting up git hooks..."
	@if [ ! -d ".git" ]; then \
		echo "$(RED)[ERROR]$(RESET) Not in a git repository"; \
		exit 1; \
	fi
	@chmod +x scripts/setup-hooks.sh
	@./scripts/setup-hooks.sh
	@echo "$(GREEN)[SUCCESS]$(RESET) Git hooks installed!"

hooks-test: ## Test git hooks manually
	@echo "$(GREEN)[INFO]$(RESET) Testing git hooks..."
	@if [ -f ".git/hooks/pre-commit" ]; then \
		echo "$(YELLOW)[INFO]$(RESET) Testing pre-commit hook..."; \
		./.git/hooks/pre-commit; \
	else \
		echo "$(RED)[ERROR]$(RESET) Pre-commit hook not found. Run: make hooks"; \
	fi

hooks-remove: ## Remove git hooks
	@echo "$(GREEN)[INFO]$(RESET) Removing git hooks..."
	@rm -f .git/hooks/pre-commit .git/hooks/pre-push .git/hooks/commit-msg
	@echo "$(GREEN)[SUCCESS]$(RESET) Git hooks removed!"

help: ## Show this help message
	@echo "$(CYAN)LastPlace.nvim Development Commands:$(RESET)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(CYAN)%-15s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Quick start:$(RESET)"
	@echo "  make install  # Install dependencies"
	@echo "  make hooks    # Setup git hooks"
	@echo "  make dev      # Start development"
