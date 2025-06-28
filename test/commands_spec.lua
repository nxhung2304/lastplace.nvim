local spec_helper = require("test.spec_helper")
spec_helper.setup_vim_mocks()

local commands = require("lastplace.commands")
local config = require("lastplace.config")

describe("lastplace.commands", function()
  before_each(function()
    config.setup() -- Reset to defaults
  end)

  describe("setup", function()
    it("should create all user commands", function()
      local created_commands = {}
      vim.api.nvim_create_user_command = function(name, callback, opts)
        created_commands[name] = { callback = callback, opts = opts }
      end

      commands.setup()

      assert.is_not_nil(created_commands["LastPlaceJump"])
      assert.is_not_nil(created_commands["LastPlaceToggle"])
      assert.is_not_nil(created_commands["LastPlaceInfo"])
      assert.is_not_nil(created_commands["LastPlaceReset"])
    end)

    it("should create commands with proper descriptions", function()
      local command_descs = {}
      vim.api.nvim_create_user_command = function(name, callback, opts)
        command_descs[name] = opts.desc
      end

      commands.setup()

      assert.is_string(command_descs["LastPlaceJump"])
      assert.is_string(command_descs["LastPlaceToggle"])
      assert.matches("jump", command_descs["LastPlaceJump"]:lower())
      assert.matches("toggle", command_descs["LastPlaceToggle"]:lower())
    end)
  end)

  describe("LastPlaceToggle command", function()
    it("should toggle center_on_jump setting", function()
      config.setup({ center_on_jump = true })

      local toggle_callback
      vim.api.nvim_create_user_command = function(name, callback, opts)
        if name == "LastPlaceToggle" then
          toggle_callback = callback
        end
      end

      commands.setup()

      -- Test toggle
      toggle_callback()
      assert.is_false(config.get().center_on_jump)

      toggle_callback()
      assert.is_true(config.get().center_on_jump)
    end)
  end)

  describe("LastPlaceReset command", function()
    it("should reset configuration to defaults", function()
      -- Modify config
      config.setup({ center_on_jump = false, min_lines = 99 })

      local reset_callback
      vim.api.nvim_create_user_command = function(name, callback, opts)
        if name == "LastPlaceReset" then
          reset_callback = callback
        end
      end

      commands.setup()
      reset_callback()

      local cfg = config.get()
      assert.is_true(cfg.center_on_jump)
      assert.equals(10, cfg.min_lines)
    end)
  end)
end)
