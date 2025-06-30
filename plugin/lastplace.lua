if vim.g.loaded_lastplace then
  return
end
vim.g.loaded_lastplace = true

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    if not vim.g.lastplace_setup_called then
      require("lastplace").setup()
    end
  end,
})
