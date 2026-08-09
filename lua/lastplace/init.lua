---@class lastplace
local M = {}

local config = require("lastplace.config")
local core = require("lastplace.core")

---@param user_config? lastplace.Opts
function M.setup(user_config)
  config.setup(user_config)

  core.setup()

  require("lastplace.commands").setup()

  if config.get().debug then
    vim.notify("[lastplace.nvim] Plugin initialized", vim.log.levels.DEBUG)
  end
end

M.config = config.get
M.is_ignored = core.is_buffer_ignored
M.jump = core.jump_to_last_place

return M
