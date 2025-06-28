local spec_helper = require("test.spec_helper")
spec_helper.setup_vim_mocks()

local lastplace = require("lastplace")

describe("lastplace integration", function()
  before_each(function()
    spec_helper.reset_buffer_state()
  end)

  describe("full plugin workflow", function()
    it("should setup and work end-to-end", function()
      -- Setup plugin
      lastplace.setup({
        center_on_jump = true,
        min_lines = 5,
        ignore_filetypes = { "test" }
      })

      -- Test ignored file
      spec_helper.setup_test_file({ filetype = "test" })
      assert.is_true(lastplace.is_ignored())

      -- Test normal file
      spec_helper.setup_test_file({
        filetype = "lua",
        total_lines = 100,
        last_line = 50
      })
      assert.is_false(lastplace.is_ignored())

      -- Test manual jump
      local jump_called = false
      vim.api.nvim_win_set_cursor = function()
        jump_called = true
      end

      local result = lastplace.jump()
      assert.is_true(result)
      assert.is_true(jump_called)
    end)

    it("should expose proper API", function()
      lastplace.setup()

      assert.is_function(lastplace.jump)
      assert.is_function(lastplace.config)
      assert.is_function(lastplace.is_ignored)
    end)
  end)
end)
