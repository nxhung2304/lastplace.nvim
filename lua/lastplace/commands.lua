local M = {}

local config = require("lastplace.config")
local core = require("lastplace.core")

function M.setup()
  vim.api.nvim_create_user_command("LastPlaceJump", function()
    local success = core.jump_to_last_place()
    if success then
      vim.notify("Jumped to last cursor position")
    else
      vim.notify("Could not jump to last position", vim.log.levels.WARN)
    end
  end, {
    desc = "Manually jump to last cursor position",
  })

  vim.api.nvim_create_user_command("LastPlaceToggle", function()
    local cfg = config.get()
    cfg.center_on_jump = not cfg.center_on_jump
    vim.notify("LastPlace centering: " .. (cfg.center_on_jump and "enabled" or "disabled"))
  end, {
    desc = "Toggle centering after jump",
  })

  vim.api.nvim_create_user_command("LastPlaceInfo", function()
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
  end, {
    desc = "Show LastPlace plugin information",
  })

  vim.api.nvim_create_user_command("LastPlaceReset", function()
    config.setup(config.get_default())
    vim.notify("LastPlace configuration reset to defaults")
  end, {
    desc = "Reset LastPlace configuration to defaults",
  })
end

return M
