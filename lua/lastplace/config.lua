local M = {}

local default_config = {
  ignore_filetypes = {
    "gitcommit",
    "gitrebase",
    "svn",
    "hgcommit",
    "xxd",
    "COMMIT_EDITMSG",
  },

  ignore_buftypes = {
    "quickfix",
    "nofile",
    "help",
    "terminal",
  },

  center_on_jump = true,
  jump_only_if_not_visible = false,
  min_lines = 10,
  max_line = 0,
  open_folds = true,
  debug = false,
}

local current_config = {}

function M.setup(user_config)
  current_config = vim.tbl_deep_extend("force", default_config, user_config or {})
end

function M.get()
  return current_config
end

function M.get_default()
  return default_config
end

return M
