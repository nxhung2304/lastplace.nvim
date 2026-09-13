local config = require("lastplace.config")
local core = require("lastplace.core")

---@param n integer
---@return string[]
local function make_lines(n)
  local lines = {}
  for i = 1, n do
    lines[i] = "line " .. i
  end
  return lines
end

---@param total_lines integer
---@param last_line? integer
---@param last_col? integer
local function make_buffer(total_lines, last_line, last_col)
  local bufnr = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_win_set_buf(0, bufnr)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, make_lines(total_lines))
  if last_line then
    vim.fn.setpos("'\"", { bufnr, last_line, last_col or 1, 0 })
  end
end

describe("lastplace.core", function()
  before_each(function()
    config.setup(config.get_default())
    vim.g.SessionLoad = nil
  end)

  after_each(function()
    vim.cmd("silent! bwipeout!")
  end)

  it("jumps to the last position on a normal file", function()
    local total_lines = 20
    local last_line = 12
    local last_col = 3
    make_buffer(total_lines, last_line, last_col)

    local jumped = core.jump_to_last_place()

    assert.is_true(jumped)
    assert.same({ last_line, last_col - 1 }, vim.api.nvim_win_get_cursor(0))
  end)

  it("skips files shorter than min_lines", function()
    local min_lines = 10
    local total_lines = min_lines - 1
    config.setup({ min_lines = min_lines })
    make_buffer(total_lines, 3, 1)

    local jumped = core.jump_to_last_place()

    assert.is_false(jumped)
    assert.same({ 1, 0 }, vim.api.nvim_win_get_cursor(0))
  end)

  it("skips when the mark points past the end of the file", function()
    local total_lines = 20
    make_buffer(total_lines, 12, 1)
    vim.fn.setpos("'\"", { 0, total_lines + 1, 1, 0 })

    local jumped = core.jump_to_last_place()

    assert.is_false(jumped)
  end)

  it("skips an empty file", function()
    local empty_file_lines = 1
    make_buffer(empty_file_lines)

    local jumped = core.jump_to_last_place()

    assert.is_false(jumped)
  end)

  it("skips ignored filetypes", function()
    make_buffer(20, 12, 1)
    vim.bo.filetype = "gitcommit"

    local jumped = core.jump_to_last_place()

    assert.is_false(jumped)
  end)

  it("skips ignored buftypes", function()
    make_buffer(20, 12, 1)
    vim.bo.buftype = "nofile"

    local jumped = core.jump_to_last_place()

    assert.is_false(jumped)
  end)

  it("skips when last_line exceeds max_line", function()
    local max_line = 5
    local last_line = max_line + 1
    config.setup({ max_line = max_line })
    make_buffer(20, last_line, 1)

    local jumped = core.jump_to_last_place()

    assert.is_false(jumped)
  end)

  it("does not jump when jump_only_if_not_visible and the line is already visible", function()
    local window_height = 10
    local visible_line = 5
    config.setup({ jump_only_if_not_visible = true })
    make_buffer(100, visible_line, 1)
    vim.api.nvim_win_set_height(0, window_height)
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    vim.cmd("normal! zt")

    local jumped = core.jump_to_last_place()

    assert.is_false(jumped)
  end)

  it("jumps when jump_only_if_not_visible and the line is not visible", function()
    local window_height = 10
    local hidden_line = 90
    config.setup({ jump_only_if_not_visible = true })
    make_buffer(100, hidden_line, 1)
    vim.api.nvim_win_set_height(0, window_height)
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    vim.cmd("normal! zt")

    local jumped = core.jump_to_last_place()

    assert.is_true(jumped)
    assert.equals(hidden_line, vim.api.nvim_win_get_cursor(0)[1])
  end)

  it("opens a closed fold covering the last position when open_folds is true", function()
    local fold_start = 5
    local fold_end = 15
    local last_line = 10
    config.setup({ open_folds = true })
    make_buffer(30, last_line, 1)
    vim.wo.foldenable = true
    vim.wo.foldmethod = "manual"
    vim.cmd(("%d,%dfold"):format(fold_start, fold_end))
    assert.equals(fold_start, vim.fn.foldclosed(last_line))

    local jumped = core.jump_to_last_place()

    assert.is_true(jumped)
    assert.equals(-1, vim.fn.foldclosed(last_line))
  end)

  it("skips the jump while a session is being loaded", function()
    make_buffer(20, 12, 1)
    vim.g.SessionLoad = 1

    local jumped = core.jump_to_last_place()

    assert.is_false(jumped)
    assert.same({ 1, 0 }, vim.api.nvim_win_get_cursor(0))
  end)

  it("does not duplicate autocmds when setup() is called more than once", function()
    core.setup()
    core.setup()

    local autocmds = vim.api.nvim_get_autocmds({ group = "LastPlace" })
    assert.equals(1, #autocmds)
  end)
end)
