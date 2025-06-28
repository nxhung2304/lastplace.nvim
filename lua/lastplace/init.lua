local M = {}

local config = require("lastplace.config")
local core = require("lastplace.core")
local commands = require("lastplace.commands")

function M.setup(user_config)
  config.setup(user_config)

  core.setup()

  commands.setup()

  if config.get().debug then
    vim.notify("[lastplace.nvim] Plugin initialized", vim.log.levels.DEBUG)
  end
end

M.jump = core.jump_to_last_place
M.config = config.get
M.is_ignored = core.is_buffer_ignored

return M
