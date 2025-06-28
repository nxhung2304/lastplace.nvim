local spec_helper = require("test.spec_helper")
spec_helper.setup_vim_mocks()

local core = require("lastplace.core")
local config = require("lastplace.config")

describe("lastplace.core", function()
  before_each(function()
    spec_helper.reset_buffer_state()
    config.setup() -- Reset to defaults
  end)

  describe("is_buffer_ignored", function()
    it("should ignore gitcommit filetype", function()
      spec_helper.setup_test_file({ filetype = "gitcommit" })
      assert.is_true(core.is_buffer_ignored())
    end)

    it("should ignore help buftype", function()
      spec_helper.setup_test_file({ buftype = "help" })
      assert.is_true(core.is_buffer_ignored())
    end)

    it("should not ignore normal files", function()
      spec_helper.setup_test_file({ filetype = "lua", buftype = "" })
      assert.is_false(core.is_buffer_ignored())
    end)

    it("should respect custom ignore lists", function()
      config.setup({
        ignore_filetypes = { "dart" },
        ignore_buftypes = { "custom" }
      })

      spec_helper.setup_test_file({ filetype = "dart" })
      assert.is_true(core.is_buffer_ignored())

      spec_helper.setup_test_file({ filetype = "lua", buftype = "custom" })
      assert.is_true(core.is_buffer_ignored())
    end)
  end)

  describe("jump_to_last_place", function()
    it("should return false for ignored filetypes", function()
      spec_helper.setup_test_file({ filetype = "gitcommit" })
      local result = core.jump_to_last_place()
      assert.is_false(result)
    end)

    it("should return false for files with insufficient lines", function()
      config.setup({ min_lines = 20 })
      spec_helper.setup_test_file({
        filetype = "lua",
        total_lines = 10,
        last_line = 5
      })

      local result = core.jump_to_last_place()
      assert.is_false(result)
    end)

    it("should return false for invalid last positions", function()
      spec_helper.setup_test_file({
        filetype = "lua",
        total_lines = 100,
        last_line = 0 -- Invalid position
      })

      local result = core.jump_to_last_place()
      assert.is_false(result)
    end)

    it("should return false when last line exceeds max_line setting", function()
      config.setup({ max_line = 50 })
      spec_helper.setup_test_file({
        filetype = "lua",
        total_lines = 100,
        last_line = 75 -- Exceeds max_line
      })

      local result = core.jump_to_last_place()
      assert.is_false(result)
    end)

    it("should return true for valid jump conditions", function()
      spec_helper.setup_test_file({
        filetype = "lua",
        total_lines = 100,
        last_line = 50
      })

      local jump_called = false
      vim.api.nvim_win_set_cursor = function()
        jump_called = true
      end

      local result = core.jump_to_last_place()
      assert.is_true(result)
      assert.is_true(jump_called)
    end)

    it("should center cursor when center_on_jump is enabled", function()
      config.setup({ center_on_jump = true })
      spec_helper.setup_test_file({
        filetype = "lua",
        total_lines = 100,
        last_line = 50
      })

      local center_called = false
      vim.cmd = function(cmd)
        if cmd == "normal! zz" then
          center_called = true
        end
      end

      core.jump_to_last_place()
      assert.is_true(center_called)
    end)

    it("should open folds when open_folds is enabled", function()
      config.setup({ open_folds = true })
      spec_helper.setup_test_file({
        filetype = "lua",
        total_lines = 100,
        last_line = 50
      })

      local fold_opened = false
      vim.cmd = function(cmd)
        if cmd == "normal! zv" then
          fold_opened = true
        end
      end

      core.jump_to_last_place()
      assert.is_true(fold_opened)
    end)
  end)

  describe("setup", function()
    it("should create autocommand group", function()
      local group_created = false
      vim.api.nvim_create_augroup = function(name, opts)
        if name == "LastPlace" and opts.clear then
          group_created = true
        end
        return 1
      end

      core.setup()
      assert.is_true(group_created)
    end)

    it("should create BufReadPost autocommand", function()
      local autocmd_created = false
      vim.api.nvim_create_autocmd = function(event, opts)
        if event == "BufReadPost" and opts.callback == core.jump_to_last_place then
          autocmd_created = true
        end
      end

      core.setup()
      assert.is_true(autocmd_created)
    end)
  end)
end)
