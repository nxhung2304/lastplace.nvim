# lastplace.nvim

🎯 Automatically jump to last cursor position when reopening files

## Features

- ✅ Smart filetype detection (ignores git commits, help files, etc.)
- ✅ Configurable buffer type filtering
- ✅ Optional cursor centering
- ✅ Minimum file size requirements
- ✅ Fold opening support
- ✅ Debug mode for troubleshooting
- ✅ Manual commands for control

## Installation

### With lazy.nvim
```lua
{
  "nxhung2304/lastplace.nvim",
  event = {
    "BufReadPost"
  },
  config = function()
    require("lastplace").setup()
  end,
}
```

### With packer.nvim
```lua
use {
  "nxhung2304/lastplace.nvim",
  config = function()
    require("lastplace").setup()
  end,
}
```

## Configuration

```lua
require("lastplace").setup({
  ignore_filetypes = {
    "gitcommit", "gitrebase", "svn", "hgcommit"
  },
  ignore_buftypes = {
    "quickfix", "nofile", "help", "terminal"
  },
  center_on_jump = true,
  jump_only_if_not_visible = false,
  min_lines = 10,
  max_line = 0,
  open_folds = true,
  debug = false,
})
```

## Commands

- `:LastPlaceJump` - Manually jump to last cursor position
- `:LastPlaceToggle` - Toggle cursor centering
