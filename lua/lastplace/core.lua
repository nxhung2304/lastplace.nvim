local M = {}

local config = require("lastplace.config")

local function debug_log(msg)
  local cfg = config.get()
  if cfg.debug then
    vim.notify("[lastplace.nvim] " .. msg, vim.log.levels.DEBUG)
  end
end

local function should_ignore_filetype(filetype)
  local cfg = config.get()
  for _, ft in ipairs(cfg.ignore_filetypes) do
    if filetype == ft then
      return true
    end
  end
  return false
end

local function should_ignore_buftype(buftype)
  local cfg = config.get()
  for _, bt in ipairs(cfg.ignore_buftypes) do
    if buftype == bt then
      return true
    end
  end
  return false
end

local function is_line_visible(line_num)
  local win_top = vim.fn.line("w0")
  local win_bottom = vim.fn.line("w$")
  return line_num >= win_top and line_num <= win_bottom
end

function M.is_buffer_ignored()
  local filetype = vim.bo.filetype
  local buftype = vim.bo.buftype

  return should_ignore_filetype(filetype) or should_ignore_buftype(buftype)
end

function M.jump_to_last_place()
  local cfg = config.get()

  local last_line = vim.fn.line("'\"")
  local last_col = vim.fn.col("'\"")

  local total_lines = vim.fn.line("$")
  local filetype = vim.bo.filetype
  local buftype = vim.bo.buftype
  local bufname = vim.fn.expand("%")

  debug_log(string.format(
    "Buffer: %s, FileType: %s, BufType: %s, LastPos: %d:%d, Total: %d",
    bufname, filetype, buftype, last_line, last_col, total_lines
  ))

  if should_ignore_filetype(filetype) then
    debug_log("Ignoring due to filetype: " .. filetype)
    return false
  end

  if should_ignore_buftype(buftype) then
    debug_log("Ignoring due to buftype: " .. buftype)
    return false
  end

  if total_lines < cfg.min_lines then
    debug_log("File too short: " .. total_lines .. " lines")
    return false
  end

  if last_line < 1 or last_line > total_lines then
    debug_log("Invalid last position: " .. last_line)
    return false
  end

  if cfg.max_line > 0 and last_line > cfg.max_line then
    debug_log("Last position exceeds max_line: " .. last_line)
    return false
  end

  if cfg.jump_only_if_not_visible and is_line_visible(last_line) then
    debug_log("Line already visible, skipping jump")
    return false
  end

  vim.api.nvim_win_set_cursor(0, { last_line, math.max(0, last_col - 1) })
  debug_log(string.format("Jumped to position %d:%d", last_line, last_col))

  if cfg.open_folds then
    vim.cmd("normal! zv")
  end

  if cfg.center_on_jump then
    vim.cmd("normal! zz")
    debug_log("Centered cursor")
  end

  return true
end

function M.setup()
  local group = vim.api.nvim_create_augroup("LastPlace", { clear = true })

  vim.api.nvim_create_autocmd("BufReadPost", {
    group = group,
    desc = "Jump to last cursor position",
    pattern = "*",
    callback = M.jump_to_last_place,
  })
end

return M
