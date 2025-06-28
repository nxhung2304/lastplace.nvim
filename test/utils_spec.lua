local spec_helper = require("test.spec_helper")
spec_helper.setup_vim_mocks()

local utils = require("lastplace.utils")

describe("lastplace.utils", function()
  before_each(function()
    spec_helper.reset_buffer_state()
  end)

  describe("is_at_beginning", function()
    it("should return true when at position 1:1", function()
      vim.fn.line = function(mark)
        if mark == "." then return 1 end
        return 1
      end
      vim.fn.col = function(mark)
        if mark == "." then return 1 end
        return 1
      end

      assert.is_true(utils.is_at_beginning())
    end)

    it("should return false when not at beginning", function()
      vim.fn.line = function(mark)
        if mark == "." then return 5 end
        return 1
      end

      assert.is_false(utils.is_at_beginning())
    end)
  end)

  describe("get_file_stats", function()
    it("should return comprehensive file statistics", function()
      spec_helper.setup_test_file({
        filetype = "lua",
        total_lines = 100
      })

      local stats = utils.get_file_stats()

      assert.equals(100, stats.total_lines)
      assert.equals("lua", stats.filetype)
      assert.is_table(stats.last_position)
      assert.is_number(stats.current_line)
      assert.is_number(stats.current_col)
    end)
  end)

  describe("format_position", function()
    it("should format position as line:column", function()
      assert.equals("10:5", utils.format_position(10, 5))
      assert.equals("1:1", utils.format_position(1, 1))
      assert.equals("999:123", utils.format_position(999, 123))
    end)
  end)
end)
