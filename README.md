# 🎯 lastplace.nvim

*Intelligently restore your cursor position when reopening files in Neovim*

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Neovim](https://img.shields.io/badge/Neovim-0.7+-green.svg)](https://neovim.io)

## ✨ Features

- **Smart Detection** - Automatically ignores git commits, help files, and other special buffers
- **Highly Configurable** - Extensive options for fine-tuning behavior
- **Precise Positioning** - Optional cursor centering and fold opening
- **Manual Control** - Commands for manual jumping and configuration

## 📦 Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "nxhung2304/lastplace.nvim",
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

## 🙏 Acknowledgments

- Inspired by [vim-lastplace](https://github.com/farmergreg/vim-lastplace), [nvim-lastplace](https://github.com/ethanholz/nvim-lastplace)
- Thanks to the Neovim community for feedback and contributions
