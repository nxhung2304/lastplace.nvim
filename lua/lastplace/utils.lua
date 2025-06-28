local M = {}

function M.is_at_beginning()
  local line = vim.fn.line(".")
  local col = vim.fn.col(".")
  return line == 1 and col == 1
end

function M.get_file_stats()
  return {
    total_lines = vim.fn.line("$"),
    current_line = vim.fn.line("."),
    current_col = vim.fn.col("."),
    last_position = { vim.fn.line("'\""), vim.fn.col("'\"") },
    filetype = vim.bo.filetype,
    buftype = vim.bo.buftype,
  }
end

function M.format_position(line, col)
  return string.format("%d:%d", line, col)
end

return M
