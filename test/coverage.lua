local M = {}

local coverage_data = {}

function M.track_function(module, func_name)
  coverage_data[module] = coverage_data[module] or {}
  coverage_data[module][func_name] = (coverage_data[module][func_name] or 0) + 1
end

function M.run()
  local plenary = require('plenary.test_harness')

  local original_require = require
  _G.require = function(name)
    local module = original_require(name)
    if name:match("^lastplace") then
      M.instrument_module(name, module)
    end
    return module
  end

  plenary.test_directory("test/", { minimal_init = "test/minimal_init.lua" })

  M.generate_report()
end

function M.instrument_module(name, module)
  for key, value in pairs(module) do
    if type(value) == "function" then
      module[key] = function(...)
        M.track_function(name, key)
        return value(...)
      end
    end
  end
end

function M.generate_report()
  print("\n=== COVERAGE REPORT ===")
  for module, functions in pairs(coverage_data) do
    print(string.format("Module: %s", module))
    for func, count in pairs(functions) do
      print(string.format("  %s: called %d times", func, count))
    end
  end

  local total_functions = 0
  local covered_functions = 0

  for _, functions in pairs(coverage_data) do
    for _, count in pairs(functions) do
      total_functions = total_functions + 1
      if count > 0 then
        covered_functions = covered_functions + 1
      end
    end
  end

  local coverage_percent = total_functions > 0 and (covered_functions / total_functions * 100) or 0
  print(string.format("\nTotal Coverage: %.1f%% (%d/%d functions)",
    coverage_percent, covered_functions, total_functions))
end

return M
