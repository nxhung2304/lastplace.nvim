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

  -- Buffer types to ignore
  ignore_buftypes = {
    "quickfix",
    "nofile",
    "help",
    "terminal",
  },

  -- Center the cursor line after jumping
  center_on_jump = true,

  -- Only jump if the target line is not visible
  jump_only_if_not_visible = false,

  -- Minimum number of lines in file to enable jumping
  min_lines = 10,

  -- Maximum line number to jump to (0 = no limit)
  max_line = 0,

  -- Open folds after jumping
  open_folds = true,

  -- Enable debug messages
  debug = false,
}

-- Current configuration
local config = {}

-- Debug function
local function debug_log(msg)
  if config.debug then
    vim.notify("[lastplace.nvim] " .. msg, vim.log.levels.DEBUG)
  end
end

-- Check if filetype should be ignored
local function should_ignore_filetype(filetype)
  for _, ft in ipairs(config.ignore_filetypes) do
    if filetype == ft then
      return true
    end
  end
  return false
end

-- Check if buffer type should be ignored
local function should_ignore_buftype(buftype)
  for _, bt in ipairs(config.ignore_buftypes) do
    if buftype == bt then
      return true
    end
  end
  return false
end

-- Check if line is visible in current window
local function is_line_visible(line_num)
  local win_top = vim.fn.line("w0")
  local win_bottom = vim.fn.line("w$")
  return line_num >= win_top and line_num <= win_bottom
end

-- Main jump function
local function jump_to_last_place()
  -- Get last cursor position mark
  local last_line = vim.fn.line("'\"")
  local last_col = vim.fn.col("'\"")

  -- Get current buffer info
  local current_line = vim.fn.line(".")
  local total_lines = vim.fn.line("$")
  local filetype = vim.bo.filetype
  local buftype = vim.bo.buftype
  local bufname = vim.fn.expand("%")

  debug_log(string.format(
    "Buffer: %s, FileType: %s, BufType: %s, LastPos: %d:%d, Total: %d",
    bufname, filetype, buftype, last_line, last_col, total_lines
  ))

  -- Check if we should ignore this buffer
  if should_ignore_filetype(filetype) then
    debug_log("Ignoring due to filetype: " .. filetype)
    return
  end

  if should_ignore_buftype(buftype) then
    debug_log("Ignoring due to buftype: " .. buftype)
    return
  end

  -- Check minimum lines requirement
  if total_lines < config.min_lines then
    debug_log("File too short: " .. total_lines .. " lines")
    return
  end

  -- Check if last position is valid
  if last_line < 1 or last_line > total_lines then
    debug_log("Invalid last position: " .. last_line)
    return
  end

  -- Check maximum line limit
  if config.max_line > 0 and last_line > config.max_line then
    debug_log("Last position exceeds max_line: " .. last_line)
    return
  end

  -- Check if we should only jump when not visible
  if config.jump_only_if_not_visible and is_line_visible(last_line) then
    debug_log("Line already visible, skipping jump")
    return
  end

  -- Jump to last position
  vim.api.nvim_win_set_cursor(0, { last_line, math.max(0, last_col - 1) })
  debug_log(string.format("Jumped to position %d:%d", last_line, last_col))

  -- Open folds if enabled
  if config.open_folds then
    vim.cmd("normal! zv")
  end

  -- Center cursor if enabled
  if config.center_on_jump then
    vim.cmd("normal! zz")
    debug_log("Centered cursor")
  end
end

-- Setup function
function M.setup(user_config)
  -- Merge user config with defaults
  config = vim.tbl_deep_extend("force", default_config, user_config or {})

  -- Create autocommand
  local group = vim.api.nvim_create_augroup("LastPlace", { clear = true })

  vim.api.nvim_create_autocmd("BufReadPost", {
    group = group,
    desc = "Jump to last cursor position",
    pattern = "*",
    callback = jump_to_last_place,
  })

  -- Optional: Add user commands for manual control
  vim.api.nvim_create_user_command("LastPlaceJump", jump_to_last_place, {
    desc = "Manually jump to last cursor position"
  })

  vim.api.nvim_create_user_command("LastPlaceToggle", function()
    config.center_on_jump = not config.center_on_jump
    vim.notify("LastPlace centering: " .. (config.center_on_jump and "enabled" or "disabled"))
  end, {
    desc = "Toggle centering after jump"
  })

  debug_log("LastPlace.nvim initialized with config: " .. vim.inspect(config))
end

-- Expose config for other modules or debugging
function M.get_config()
  return config
end

return M
