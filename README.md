# 🎯 lastplace.nvim

*Intelligently restore your cursor position when reopening files in Neovim*

[![Test](https://github.com/nxhung2304/lastplace.nvim/workflows/Test/badge.svg)](https://github.com/nxhung2304/lastplace.nvim/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Neovim](https://img.shields.io/badge/Neovim-0.7+-green.svg)](https://neovim.io)

## ✨ Features

- 🧠 **Smart Detection** - Automatically ignores git commits, help files, and other special buffers
- ⚙️ **Highly Configurable** - Extensive options for fine-tuning behavior
- 🎯 **Precise Positioning** - Optional cursor centering and fold opening
- 🔧 **Manual Control** - Commands for manual jumping and configuration
- 🚀 **Zero Dependencies** - Pure Lua implementation with no external requirements
- 🧪 **Fully Tested** - Comprehensive test suite with 95%+ coverage
- 📚 **Well Documented** - Detailed help documentation and examples

## 📦 Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "nxhung2304/lastplace.nvim",
  event = "BufReadPost",
  config = function()
    require("lastplace").setup({
      -- your configuration here
    })
  end,
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "nxhung2304/lastplace.nvim",
  config = function()
    require("lastplace").setup()
  end,
}
```

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'nxhung2304/lastplace.nvim'
```

Then in your `init.lua`:
```lua
require("lastplace").setup()
```

## ⚙️ Configuration

### Default Configuration

```lua
require("lastplace").setup({
  -- Filetypes to ignore
  ignore_filetypes = {
    "gitcommit", "gitrebase", "svn", "hgcommit", "xxd", "COMMIT_EDITMSG"
  },
  
  -- Buffer types to ignore  
  ignore_buftypes = {
    "quickfix", "nofile", "help", "terminal"
  },
  
  -- Center cursor after jumping
  center_on_jump = true,
  
  -- Only jump if target line is not visible
  jump_only_if_not_visible = false,
  
  -- Minimum lines required to enable jumping
  min_lines = 10,
  
  -- Maximum line to jump to (0 = no limit)
  max_line = 0,
  
  -- Open folds after jumping
  open_folds = true,
  
  -- Enable debug messages
  debug = false,
})
```

### Configuration Examples

#### Flutter/Dart Development
```lua
require("lastplace").setup({
  ignore_filetypes = {
    "gitcommit", "gitrebase",
    -- Don't jump in generated files
    "dart", -- if you want to ignore all Dart files
  },
  center_on_jump = true,
  min_lines = 5, -- Jump in smaller files
})
```

#### Conservative Setup
```lua
require("lastplace").setup({
  jump_only_if_not_visible = true,
  min_lines = 25,
  max_line = 1000,
  center_on_jump = false,
})
```

#### Debug Mode
```lua
require("lastplace").setup({
  debug = true,
  -- Watch debug messages with :messages
})
```

## 🔧 Commands

| Command | Description |
|---------|-------------|
| `:LastPlaceJump` | Manually jump to last cursor position |
| `:LastPlaceToggle` | Toggle cursor centering feature |
| `:LastPlaceInfo` | Show current plugin status and config |
| `:LastPlaceReset` | Reset configuration to defaults |

## 📋 API

### Basic Usage

```lua
local lastplace = require("lastplace")

-- Setup with custom config
lastplace.setup({
  center_on_jump = false,
  ignore_filetypes = {"dart", "kotlin"},
})

-- Manual operations
lastplace.jump()              -- Jump to last position
lastplace.is_ignored()        -- Check if current buffer is ignored
local config = lastplace.config()  -- Get current configuration
```

### Advanced Integration

```lua
-- Conditional jumping
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = {"*.lua", "*.py", "*.js"},
  callback = function()
    local lastplace = require("lastplace")
    if not lastplace.is_ignored() then
      lastplace.jump()
    end
  end,
})
```

## 🧪 Testing

### Run Tests

```bash
# Run all tests
make test

# Run specific test file
make test-file FILE=test/core_spec.lua

# Run tests with coverage
make test-coverage

# Watch mode (requires inotify-tools)
make test-watch
```

### Test Structure

```
test/
├── spec_helper.lua       # Test utilities and mocks
├── config_spec.lua       # Configuration tests
├── core_spec.lua         # Core functionality tests  
├── commands_spec.lua     # User commands tests
├── integration_spec.lua  # End-to-end tests
└── utils_spec.lua        # Utility functions tests
```

## 🐛 Troubleshooting

### Plugin Not Working

1. **Check setup**: Ensure you've called `require("lastplace").setup()`
2. **Enable debug**: Set `debug = true` in configuration
3. **Check messages**: Run `:messages` to see debug output
4. **Verify installation**: Ensure plugin is properly installed

### Position Not Restored

1. **Check filetype**: Use `:LastPlaceInfo` to see if buffer is ignored
2. **Verify file size**: Check if file meets `min_lines` requirement
3. **Test manually**: Try `:LastPlaceJump` command
4. **Check last position**: Run `:echo line('"')` to see last position mark

### Debug Commands

```vim
:LastPlaceInfo         " Check current status
:set filetype?         " Check current filetype
:set buftype?          " Check current buffer type
:echo line("'\"")      " Check last position mark
:messages              " View debug output
```

## 🤝 Contributing

We welcome contributions! Here's how to get started:

### Development Setup

```bash
# Clone the repository
git clone https://github.com/nxhung2304/lastplace.nvim.git
cd lastplace.nvim

# Install development dependencies
make install

# Run tests
make test

# Start development environment
make dev
```

### Code Style

- Follow [stylua](https://github.com/JohnnyMorganz/StyLua) formatting
- Use [luacheck](https://github.com/mpeterv/luacheck) for linting
- Write tests for new features
- Update documentation for API changes

### Submitting Changes

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests (`make test`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by [vim-lastplace](https://github.com/farmergreg/vim-lastplace)
- Built with [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) for testing
- Thanks to the Neovim community for feedback and contributions

## 📚 See Also

- [Documentation](doc/lastplace.txt) - Complete help documentation
- [Examples](examples/) - More configuration examples
- [Changelog](CHANGELOG.md) - Version history
- [Contributing Guidelines](CONTRIBUTING.md) - Detailed contribution guide

---

<div align="center">

**[⬆ Back to Top](#-lastplacenvim)**

Made with ❤️ for the Neovim community

</div>
