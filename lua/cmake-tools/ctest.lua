local config = require("cmake-tools.config")
local utils = require("cmake-tools.utils")
local const = require("cmake-tools.const")
local log = require("cmake-tools.log")
local os = require("cmake-tools.osys")
local quickfix = require("cmake-tools.quickfix")
local cmake = require("cmake-tools")

local ctest = {}

function ctest.get_labels()
  local result = {}

  local cmd = "ctest --test-dir " .. config.build_directory .. "/ --print-labels"
  if os.iswin32 then
    cmd:gsub("/","\\")
  end
  local handle = io.popen(cmd)

  if handle == nil then
    log.error(cmd .. " failed.")
    return result
  end

  local output = handle:read("*a")
  handle:close()
  local labels = vim.split(output, '\n')

  while table.remove(labels, 1) ~= "All Labels:" do
    -- ignore output
  end

  for _, v in ipairs(labels) do
    table.insert(result, vim.trim(v))
  end
  return result
end

function ctest.run()

  if not (config.build_directory and config.build_directory:exists()) then
    -- configure it
    return cmake.generate({ bang = false, fargs = {} },
      function()
        ctest.run()
      end)
  end

  local display, label = {},{}
  table.insert(display, "all")
  table.insert(label, "")

  local labels = ctest.get_labels()
  for _, v in ipairs(labels) do
    table.insert(display, v)
    table.insert(label, v)
  end


  vim.ui.select(display, { prompt = "Select test label" },
    vim.schedule_wrap(
      function(_, idx)
        if not idx then
          return
        end
        local dir = tostring(config.build_directory)

        if os.iswin32 then
          dir:gsub("/","\\")
        end
        local args = utils.deepcopy(const.ctest_run_args)
        table.insert(args, "--test-dir")
        table.insert(args, dir)
        table.insert(args, "-L")
        table.insert(args, label[idx])
        quickfix.run("ctest", {}, args,
          {
            cmake_quickfix_opts = const.cmake_quickfix_opts
          })
      end
    )
  )
end

return ctest
