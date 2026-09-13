local commands = require("lastplace.commands")
local config = require("lastplace.config")

---@param n integer
---@return string[]
local function make_lines(n)
  local lines = {}
  for i = 1, n do
    lines[i] = "line " .. i
  end
  return lines
end

describe("lastplace.commands", function()
  before_each(function()
    config.setup(config.get_default())
    commands.setup()
  end)

  after_each(function()
    vim.cmd("silent! bwipeout!")
  end)

  it(":LastPlace jump moves the cursor to the last position", function()
    local bufnr = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_win_set_buf(0, bufnr)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, make_lines(20))
    vim.fn.setpos("'\"", { bufnr, 12, 3, 0 })

    vim.cmd("LastPlace jump")

    assert.same({ 12, 2 }, vim.api.nvim_win_get_cursor(0))
  end)
end)
