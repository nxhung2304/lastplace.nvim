-- Auto-initialization if user doesn't call setup()
if vim.g.loaded_lastplace then
  return
end

vim.g.loaded_lastplace = 1

-- Auto-setup with defaults if no manual setup
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    if not vim.g.lastplace_setup_called then
      require("lastplace").setup()
    end
  end,
})
