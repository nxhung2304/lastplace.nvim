local root = vim.fn.getcwd()
local deps = root .. "/.deps/site"

vim.opt.runtimepath:append(deps .. "/pack/deps/start/plenary.nvim")
vim.opt.runtimepath:append(root)

vim.cmd("runtime plugin/plenary.vim")

vim.o.swapfile = false
