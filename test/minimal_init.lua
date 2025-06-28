vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Set up runtime path
vim.cmd([[set runtimepath=$VIMRUNTIME]])
vim.cmd([[set packpath=/tmp/nvim/site]])

-- Add current plugin to path
local plugin_dir = vim.fn.getcwd()
vim.opt.rtp:prepend(plugin_dir)

-- Install plenary if not exists
local plenary_path = "/tmp/nvim/site/pack/testing/start/plenary.nvim"
if vim.fn.isdirectory(plenary_path) == 0 then
  vim.fn.system({
    "git",
    "clone",
    "--depth=1",
    "https://github.com/nvim-lua/plenary.nvim.git",
    plenary_path,
  })
end

-- Add plenary to runtime path
vim.opt.rtp:prepend(plenary_path)

-- Ensure plugin loads
vim.cmd("runtime! plugin/**/*.lua")

-- Basic vim setup for testing
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
