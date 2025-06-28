#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test configuration
TEST_DIR="test"
MINIMAL_INIT="test/minimal_init.lua"
COVERAGE_DIR=".coverage"

log_info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

check_dependencies() {
  log_info "Checking dependencies..."
  
  if ! command -v nvim &> /dev/null; then
    log_error "Neovim not found. Please install Neovim."
    exit 1
  fi
  
  if ! nvim --headless -c "lua require('plenary')" -c "qa" 2>/dev/null; then
    log_warn "Plenary.nvim not found. Installing..."
    mkdir -p ~/.local/share/nvim/site/pack/vendor/start/
    git clone --depth 1 https://github.com/nvim-lua/plenary.nvim.git ~/.local/share/nvim/site/pack/vendor/start/plenary.nvim
  fi
}

run_test_suite() {
  local suite=$1
  log_info "Running test suite: $suite"
  
  nvim --headless --noplugin -u "$MINIMAL_INIT" \
    -c "PlenaryBustedFile $TEST_DIR/${suite}_spec.lua" \
    -c "qa"
}

run_all_tests() {
  log_info "Running all test suites..."
  
  for test_file in "$TEST_DIR"/*_spec.lua; do
    if [ -f "$test_file" ]; then
      local suite_name=$(basename "$test_file" _spec.lua)
      echo ""
      run_test_suite "$suite_name"
    fi
  done
}

generate_coverage() {
  log_info "Generating coverage report..."
  mkdir -p "$COVERAGE_DIR"
  
  nvim --headless --noplugin -u "$MINIMAL_INIT" \
    -c "lua require('test.coverage').run()" \
    -c "qa" > "$COVERAGE_DIR/coverage.txt"
    
  log_info "Coverage report saved to $COVERAGE_DIR/coverage.txt"
}

watch_tests() {
  log_info "Starting test watch mode..."
  log_info "Watching lua/ and test/ directories for changes..."
  
  if command -v inotifywait &> /dev/null; then
    while inotifywait -r -e modify lua/ test/ 2>/dev/null; do
      echo ""
      log_info "Files changed, running tests..."
      run_all_tests
      echo ""
      log_info "Waiting for changes..."
    done
  else
    log_error "inotifywait not found. Please install inotify-tools for watch mode."
    exit 1
  fi
}

main() {
  case "${1:-all}" in
    "check")
      check_dependencies
      ;;
    "suite")
      check_dependencies
      run_test_suite "$2"
      ;;
    "all")
      check_dependencies
      run_all_tests
      ;;
    "coverage")
      check_dependencies
      generate_coverage
      ;;
    "watch")
      check_dependencies
      watch_tests
      ;;
    "help")
      echo "Usage: $0 [check|suite|all|coverage|watch|help]"
      echo ""
      echo "Commands:"
      echo "  check     - Check dependencies"
      echo "  suite     - Run specific test suite"
      echo "  all       - Run all tests (default)"
      echo "  coverage  - Generate coverage report"
      echo "  watch     - Watch for changes and run tests"
      echo "  help      - Show this help"
      ;;
    *)
      log_error "Unknown command: $1"
      main "help"
      exit 1
      ;;
  esac
}

main "$@"
