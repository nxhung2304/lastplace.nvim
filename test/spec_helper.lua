local M = {}

-- Mock vim functions for testing
function M.setup_vim_mocks()
  -- Mock vim.bo (buffer options)
  _G.vim = _G.vim or {}
  vim.bo = vim.bo or {}

  -- Mock vim.fn functions
  vim.fn = vim.fn or {}
  vim.fn.line = function(mark)
    if mark == "." then
      return 1
    end
    if mark == "$" then
      return 100
    end
    if mark == "'\"" then
      return 50
    end
    if mark == "w0" then
      return 1
    end
    if mark == "w$" then
      return 20
    end
    return 1
  end

  vim.fn.col = function(mark)
    if mark == "." then
      return 1
    end
    if mark == "'\"" then
      return 10
    end
    return 1
  end

  vim.fn.expand = function(pattern)
    if pattern == "%" then
      return "test.lua"
    end
    return "test"
  end

  -- Mock vim.api
  vim.api = vim.api or {}
  vim.api.nvim_win_set_cursor = function(win, pos) end
  vim.api.nvim_create_augroup = function()
    return 1
  end
  vim.api.nvim_create_autocmd = function() end
  vim.api.nvim_create_user_command = function() end

  -- Mock vim.cmd
  vim.cmd = function() end

  -- Mock vim.notify
  vim.notify = function() end

  -- Mock vim.log
  vim.log = { levels = { DEBUG = 1, INFO = 2, WARN = 3, ERROR = 4 } }

  -- Mock vim.tbl_deep_extend
  vim.tbl_deep_extend = function(behavior, ...)
    local result = {}
    for _, tbl in ipairs({ ... }) do
      for k, v in pairs(tbl) do
        result[k] = v
      end
    end
    return result
  end
end

-- Reset buffer state for testing
function M.reset_buffer_state()
  vim.bo.filetype = ""
  vim.bo.buftype = ""
end

-- Set up test file state
function M.setup_test_file(opts)
  opts = opts or {}
  vim.bo.filetype = opts.filetype or "lua"
  vim.bo.buftype = opts.buftype or ""

  if opts.total_lines then
    vim.fn.line = function(mark)
      if mark == "$" then
        return opts.total_lines
      end
      if mark == "." then
        return opts.current_line or 1
      end
      if mark == "'\"" then
        return opts.last_line or 1
      end
      return 1
    end
  end
end

return M
