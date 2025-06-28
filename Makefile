.PHONY: test test-file test-coverage lint format install clean help dev watch check docs release

# Colors for output
CYAN := \033[36m
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m
RESET := \033[0m

# Directories
PLENARY_DIR := ~/.local/share/nvim/site/pack/testing/start/plenary.nvim
TEST_DIR := test
LUA_DIR := lua

# Default target
help: ## Show this help message
	@echo "$(CYAN)LastPlace.nvim Development Commands:$(RESET)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(CYAN)%-15s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Quick start:$(RESET)"
	@echo "  make install  # Install dependencies"
	@echo "  make test     # Run tests"
	@echo "  make dev      # Start development"

install: ## Install development dependencies
	@echo "$(GREEN)[INFO]$(RESET) Installing plenary.nvim..."
	@mkdir -p ~/.local/share/nvim/site/pack/testing/start/
	@if [ ! -d "$(PLENARY_DIR)" ]; then \
		git clone --depth=1 https://github.com/nvim-lua/plenary.nvim.git "$(PLENARY_DIR)"; \
		echo "$(GREEN)[INFO]$(RESET) Plenary.nvim installed successfully!"; \
	else \
		echo "$(YELLOW)[INFO]$(RESET) Plenary.nvim already installed."; \
	fi

test: install ## Run all tests
	@echo "$(GREEN)[INFO]$(RESET) Running test suite..."
	@if nvim --headless -u $(TEST_DIR)/minimal_init.lua \
		-c "PlenaryBustedDirectory $(TEST_DIR)/ { minimal_init = '$(TEST_DIR)/minimal_init.lua' }"; then \
		echo "$(GREEN)[SUCCESS]$(RESET) All tests passed!"; \
	else \
		echo "$(RED)[ERROR]$(RESET) Tests failed!"; \
		exit 1; \
	fi

test-file: install ## Run specific test file (usage: make test-file FILE=test/core_spec.lua)
	@if [ -z "$(FILE)" ]; then \
		echo "$(RED)[ERROR]$(RESET) Please specify FILE parameter"; \
		echo "$(YELLOW)Usage:$(RESET) make test-file FILE=test/core_spec.lua"; \
		exit 1; \
	fi
	@echo "$(GREEN)[INFO]$(RESET) Running test file: $(FILE)"
	@nvim --headless -u $(TEST_DIR)/minimal_init.lua -c "PlenaryBustedFile $(FILE)"

test-simple: install ## Run simple test without plenary commands
	@echo "$(GREEN)[INFO]$(RESET) Running simple test mode..."
	@nvim --headless -u $(TEST_DIR)/minimal_init.lua \
		-c "lua require('plenary.test_harness').test_directory('$(TEST_DIR)/')" -c "qa"

test-coverage: install ## Run tests with coverage tracking
	@echo "$(GREEN)[INFO]$(RESET) Running tests with coverage tracking..."
	@nvim --headless -u $(TEST_DIR)/minimal_init.lua \
		-c "lua require('test.coverage').run()" -c "qa"

watch: install ## Watch for changes and run tests (requires inotifywait)
	@echo "$(GREEN)[INFO]$(RESET) Starting test watch mode..."
	@echo "$(YELLOW)[INFO]$(RESET) Watching $(LUA_DIR)/ and $(TEST_DIR)/ directories for changes..."
	@if command -v inotifywait >/dev/null 2>&1; then \
		trap 'echo "\n$(YELLOW)[INFO]$(RESET) Stopping watch mode..."; exit 0' INT; \
		while true; do \
			inotifywait -r -e modify,create,delete $(LUA_DIR)/ $(TEST_DIR)/ 2>/dev/null; \
			echo ""; \
			echo "$(YELLOW)[INFO]$(RESET) Files changed, running tests..."; \
			make test || true; \
			echo ""; \
			echo "$(GREEN)[INFO]$(RESET) Waiting for changes... (Ctrl+C to stop)"; \
		done; \
	else \
		echo "$(RED)[ERROR]$(RESET) inotifywait not found."; \
		echo "$(YELLOW)[INSTALL]$(RESET) On Ubuntu/Debian: sudo apt-get install inotify-tools"; \
		echo "$(YELLOW)[INSTALL]$(RESET) On macOS: brew install fswatch"; \
		echo "$(YELLOW)[INSTALL]$(RESET) On Arch: sudo pacman -S inotify-tools"; \
		exit 1; \
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

check: format-check lint test ## Run all checks (format + lint + test)
	@echo "$(GREEN)[SUCCESS]$(RESET) All checks passed! 🎉"

docs: ## Show documentation info
	@echo "$(GREEN)[INFO]$(RESET) Documentation locations:"
	@echo "  📖 Help file: doc/lastplace.txt"
	@echo "  📚 README: README.md"
	@echo "  🤝 Contributing: CONTRIBUTING.md"
	@echo ""
	@echo "$(YELLOW)[VIEW]$(RESET) To view help in Neovim:"
	@echo "  nvim -c 'help lastplace'"

test-debug: install ## Run tests with debug output
	@echo "$(GREEN)[INFO]$(RESET) Running tests with debug output..."
	@nvim --headless -u $(TEST_DIR)/minimal_init.lua \
		-c "lua vim.g.debug_tests = true" \
		-c "PlenaryBustedDirectory $(TEST_DIR)/ { minimal_init = '$(TEST_DIR)/minimal_init.lua' }"

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
	@echo "  ✅ All tests passed"
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
	@echo "  make test    # Run tests"
	@echo "  make dev     # Start development"
	@echo "  make check   # Run all checks"
