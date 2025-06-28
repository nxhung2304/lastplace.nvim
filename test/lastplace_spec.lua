local lastplace = require("lastplace")

describe("lastplace", function()
  before_each(function()
    -- Reset configuration
    lastplace.setup()
  end)
  
  it("should setup with default config", function()
    local config = lastplace.get_config()
    assert.is_true(config.center_on_jump)
    assert.equals(10, config.min_lines)
  end)
  
  it("should merge user config", function()
    lastplace.setup({ min_lines = 5 })
    local config = lastplace.get_config()
    assert.equals(5, config.min_lines)
    assert.is_true(config.center_on_jump) -- default preserved
  end)
end)
