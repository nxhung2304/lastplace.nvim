local spec_helper = require("test.spec_helper")
spec_helper.setup_vim_mocks()

local config = require("lastplace.config")

describe("lastplace.config", function()
  before_each(function()
    -- Reset config before each test
    config.setup()
  end)
  
  describe("setup", function()
    it("should use default configuration when no user config provided", function()
      config.setup()
      local cfg = config.get()
      
      assert.is_true(cfg.center_on_jump)
      assert.equals(10, cfg.min_lines)
      assert.is_false(cfg.debug)
      assert.same({"gitcommit", "gitrebase", "svn", "hgcommit", "xxd", "COMMIT_EDITMSG"}, cfg.ignore_filetypes)
    end)
    
    it("should merge user configuration with defaults", function()
      config.setup({
        center_on_jump = false,
        min_lines = 5,
        ignore_filetypes = {"custom"}
      })
      
      local cfg = config.get()
      assert.is_false(cfg.center_on_jump)
      assert.equals(5, cfg.min_lines)
      assert.same({"custom"}, cfg.ignore_filetypes)
      -- Default values should be preserved
      assert.equals(0, cfg.max_line)
    end)
    
    it("should handle nested configuration options", function()
      config.setup({
        ignore_buftypes = {"terminal", "quickfix"}
      })
      
      local cfg = config.get()
      assert.same({"terminal", "quickfix"}, cfg.ignore_buftypes)
    end)
  end)
  
  describe("get_default", function()
    it("should return default configuration", function()
      local default = config.get_default()
      assert.is_true(default.center_on_jump)
      assert.equals(10, default.min_lines)
    end)
    
    it("should not be affected by setup calls", function()
      config.setup({ min_lines = 99 })
      local default = config.get_default()
      assert.equals(10, default.min_lines)
    end)
  end)
end)
