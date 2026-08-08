---@class lastplace.Commands
local M = {}

local config = require("lastplace.config")
local core = require("lastplace.core")

local subcommands = {}

function subcommands.jump()
  local success = core.jump_to_last_place()
  if success then
    vim.notify("Jumped to last cursor position")
  else
    vim.notify("Could not jump to last position", vim.log.levels.WARN)
  end
end

function subcommands.toggle()
  local cfg = config.get()
  cfg.center_on_jump = not cfg.center_on_jump
  vim.notify("LastPlace centering: " .. (cfg.center_on_jump and "enabled" or "disabled"))
end

function subcommands.info()
  local cfg = config.get()
  local ignored = core.is_buffer_ignored()

  local info = {
    "LastPlace.nvim Status:",
    "- Center on jump: " .. tostring(cfg.center_on_jump),
    "- Min lines: " .. cfg.min_lines,
    "- Current buffer ignored: " .. tostring(ignored),
    "- Debug mode: " .. tostring(cfg.debug),
    "- Ignored filetypes: " .. table.concat(cfg.ignore_filetypes, ", "),
  }

  vim.notify(table.concat(info, "\n"), vim.log.levels.INFO)
end

function subcommands.reset()
  config.setup(config.get_default())
  vim.notify("LastPlace configuration reset to defaults")
end

function M.setup()
  vim.api.nvim_create_user_command("LastPlace", function(opts)
    local name = opts.fargs[1] or "jump"
    local handler = subcommands[name]

    if not handler then
      vim.notify(
        "LastPlace: unknown subcommand '" .. name .. "'. Available: jump, toggle, info, reset",
        vim.log.levels.ERROR
      )
      return
    end

    handler()
  end, {
    nargs = "?",
    desc = "LastPlace: jump | toggle | info | reset (defaults to jump)",
    ---@param arg_lead string
    ---@return string[]
    complete = function(arg_lead)
      local names = { "jump", "toggle", "info", "reset" }
      return vim.tbl_filter(function(name)
        return name:find(arg_lead, 1, true) == 1
      end, names)
    end,
  })
end

return M
