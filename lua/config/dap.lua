local dap = require "dap"
local notify = require("dap.utils").notify
local M = {}

M.json_decode = vim.json.decode
M.type_to_filetypes = {}

---@class dap.vscode.launch.Input
---@field id string
---@field type "promptString"|"pickString"
---@field description string
---@field default? string
---@field options string[]|{label: string, value: string}[]

---@param input dap.vscode.launch.Input
---@return function
local function create_input(input)
  if input.type == "promptString" then
    return function()
      local description = input.description or "Input"
      if not vim.endswith(description, ": ") then description = description .. ": " end
      if vim.ui.input then
        local co = coroutine.running()
        local opts = {
          prompt = description,
          default = input.default or "",
        }
        vim.ui.input(opts, function(result)
          vim.schedule(function() coroutine.resume(co, result) end)
        end)
        return coroutine.yield()
      else
        return vim.fn.input(description, input.default or "")
      end
    end
  elseif input.type == "pickString" then
    return function()
      local options = assert(input.options, "input of type pickString must have an `options` property")
      local opts = {
        prompt = input.description,
        format_item = function(x) return x.label and x.label or x end,
      }
      local co = coroutine.running()
      vim.ui.select(options, opts, function(option)
        vim.schedule(function()
          local value = option and option.value or option
          coroutine.resume(co, value or (input.default or ""))
        end)
      end)
      return coroutine.yield()
    end
  else
    local msg = "Unsupported input type in vscode launch.json: " .. input.type
    notify(msg, vim.log.levels.WARN)
    return function() return "${input:" .. input.id .. "}" end
  end
end

---@param inputs dap.vscode.launch.Input[]
---@return table<string, function> inputs map from ${input:<id>} to function resolving the input value
local function create_inputs(inputs)
  local result = {}
  for _, input in ipairs(inputs) do
    local id = assert(input.id, "input must have a `id`")
    local key = "${input:" .. id .. "}"
    assert(input.type, "input must have a `type`")
    local fn = create_input(input)
    if fn then result[key] = fn end
  end
  return result
end

---@param inputs table<string, function>
---@param value any
---@param cache table<string, any>
local function apply_input(inputs, value, cache)
  if type(value) == "table" then
    local new_value = {}
    for k, v in pairs(value) do
      new_value[k] = apply_input(inputs, v, cache)
    end
    value = new_value
  end
  if type(value) ~= "string" then return value end

  local matches = string.gmatch(value, "${input:([%w_]+)}")
  for input_id in matches do
    local input_key = "${input:" .. input_id .. "}"
    local result = cache[input_key]
    if not result then
      local input = inputs[input_key]
      if not input then
        local msg = "No input with id `" .. input_id .. "` found in inputs"
        notify(msg, vim.log.levels.WARN)
      else
        result = input()
        cache[input_key] = result
      end
    end
    if result then value = value:gsub(input_key, result) end
  end
  return value
end

---@param config table<string, any>
---@param inputs table<string, function>
local function apply_inputs(config, inputs)
  local result = {}
  local cache = {}
  for key, value in pairs(config) do
    result[key] = apply_input(inputs, value, cache)
  end
  return result
end

--- Lift properties of a child table to top-level
local function lift(tbl, key)
  local child = tbl[key]
  if child then
    tbl[key] = nil
    return vim.tbl_extend("force", tbl, child)
  end
  return tbl
end

function M._load_json(jsonstr)
  local data = assert(M.json_decode(jsonstr), "launch.json must contain a JSON object")
  local inputs = create_inputs(data.inputs or {})
  local has_inputs = next(inputs) ~= nil

  local sysname
  if vim.fn.has "linux" == 1 then
    sysname = "linux"
  elseif vim.fn.has "mac" == 1 then
    sysname = "osx"
  elseif vim.fn.has "win32" == 1 then
    sysname = "windows"
  end
  local configs = {}
  for _, config in ipairs(data.configurations or {}) do
    config = lift(config, sysname)
    if has_inputs then
      config = setmetatable(config, {
        __call = function()
          local c = vim.deepcopy(config)
          return apply_inputs(c, inputs)
        end,
      })
    end
    table.insert(configs, config)
  end
  return configs
end

--- Extends dap.configurations with entries read from .vscode/launch.json
function M.load_launchjs(path, type_to_filetypes)
  type_to_filetypes = vim.tbl_extend("keep", type_to_filetypes or {}, M.type_to_filetypes)
  local resolved_path = path or (vim.fn.getcwd() .. "/.vscode/launch.json")
  if not vim.loop.fs_stat(resolved_path) then return end
  local lines = {}
  for line in io.lines(resolved_path) do
    if not vim.startswith(vim.trim(line), "//") then table.insert(lines, line) end
  end
  local contents = table.concat(lines, "\n")
  local configurations = M._load_json(contents)

  assert(configurations, "launch.json must have a 'configurations' key")
  for _, config in ipairs(configurations) do
    assert(config.type, "Configuration in launch.json must have a 'type' key")
    assert(config.name, "Configuration in launch.json must have a 'name' key")
    local filetypes = type_to_filetypes[config.type] or { config.type }
    for _, filetype in pairs(filetypes) do
      local dap_configurations = dap.configurations[filetype] or {}
      for i, dap_config in pairs(dap_configurations) do
        if dap_config.name == config.name then
          -- remove old value
          table.remove(dap_configurations, i)
        end
      end
      table.insert(dap_configurations, config)
      dap.configurations[filetype] = dap_configurations
    end
  end
end

function M.load_launchjs_configurations(path)
  if not vim.loop.fs_stat(path) then return {} end
  local lines = {}
  for line in io.lines(path) do
    if not vim.startswith(vim.trim(line), "//") then table.insert(lines, line) end
  end
  local contents = table.concat(lines, "\n")
  local configurations = M._load_json(contents)

  return configurations
  -- assert(configurations, "launch.json must have a 'configurations' key")
end

function M.get_template(lang, type)
  if lang == "python" then
    if type == "current_file" then
      return {
        name = "Python: 当前文件",
        type = "python",
        request = "launch",
        program = "${file}",
        console = "integratedTerminal",
        justMyCode = false,
      }
    elseif type == "module" then
      return {
        name = "Python: 模块",
        type = "python",
        request = "launch",
        module = "enter-your-module-name",
        justMyCode = true,
      }
    end
  elseif lang == "c++" then
    if type == "launch" then
      return {
        name = "(gdb) 启动",
        type = "cppdbg",
        request = "launch",
        program = "{workspaceFolder}/a.out",
        args = {},
        stopAtEntry = false,
        cwd = "${workspaceFolder}",
        environment = {},
        externalConsole = false,
        MIMode = "gdb",
        setupCommands = {
          {
            description = "为 gdb 启用整齐打印",
            text = "-enable-pretty-printing",
            ignoreFailures = true,
          },
          {
            description = "将反汇编风格设置为 Intel",
            text = "-gdb-set disassembly-flavor intel",
            ignoreFailures = true,
          },
        },
      }
    end
  end
  return
end

local print_r = require("utils").print_r

function M.add_launchjs_from_template()
  vim.ui.select({ "python", "c++" }, {
    prompt = "select language:",
  }, function(lang)
    local types = {}
    if lang == "python" then
      types = { "current_file", "module" }
    elseif lang == "c++" then
      types = { "launch" }
    end
    vim.ui.select(types, {
      prompt = "select type",
    }, function(type) M.generate_launchjs(nil, lang, type) end)
  end)
end
function M.generate_launchjs(path, lang, type)
  if not lang or not type then return end
  local launch_path = path or (vim.fn.getcwd() .. "/.vscode/launch.json")
  local launch_data = { version = "0.2.0" }
  local configuration = M.get_template(lang, type)

  if not configuration then return end
  local configurations = {}
  if not vim.loop.fs_stat(launch_path) then
    vim.fn.mkdir(vim.fn.fnamemodify(launch_path, ":h"), "p")
    configurations = { configuration }
  else
    configurations = M.load_launchjs_configurations(launch_path)
    if configurations and #configurations > 0 then
      table.insert(configurations, configuration)
    else
      configurations = { configuration }
    end
  end

  launch_data.configurations = configurations
  local f = assert(io.open(launch_path, "w"))
  -- local launch = {
  --     version = "0.2.0",
  --     configurations = require("dap").configurations.java
  -- }
  f:write(vim.json.encode(launch_data))
  f:close()
  if vim.fn.executable "jq" == 1 then
    local obj = vim.fn.system("jq . " .. launch_path)
    print(obj)
    f = assert(io.open(launch_path, "w"))
    f:write(obj)
    f:close()
  else
    notify "jq not found, so not format."
  end
  vim.cmd(":edit " .. launch_path)
end

M.continue = function()
  if vim.fn.filereadable ".vscode/launch.json" then
    -- M.load_launchjs(nil, { cppdbg = { "c", "cpp" } })
    require("dap.ext.vscode").load_launchjs(nil, { cppdbg = { "c", "cpp" } })
  end
  require("dap").continue()
end

return M
-- require('config.dap').generate_launchjs(nil, "python", "current_file")
