---@class lastplace.Config
local M = {}

---@class lastplace.Opts
---@field center_on_jump? boolean
---@field debug? boolean
---@field ignore_buftypes? string[]
---@field ignore_filetypes? string[]
---@field jump_only_if_not_visible? boolean
---@field max_line? integer
---@field min_lines? integer
---@field open_folds? boolean
local default_config = {
  ignore_filetypes = { "COMMIT_EDITMSG", "gitcommit", "gitrebase", "hgcommit", "svn", "xxd" },
  ignore_buftypes = { "help", "nofile", "quickfix", "terminal" },
  center_on_jump = true,
  jump_only_if_not_visible = false,
  min_lines = 10,
  max_line = 0,
  open_folds = true,
  debug = false,
}

local current_config = {} ---@type lastplace.Opts

---@param user_config lastplace.Opts
function M.setup(user_config)
  current_config = vim.tbl_deep_extend("force", default_config, user_config or {}) --[[@as lastplace.Opts]]
end

---@return lastplace.Opts current_config
function M.get()
  return current_config
end

---@return lastplace.Opts default_config
function M.get_default()
  return default_config
end

return M
