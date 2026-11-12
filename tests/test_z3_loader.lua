-- Tests for rock/z3.lua's libz3 preload, on every Lua from 5.1 to 5.5 and
-- LuaJIT, with no Z3 needed: z3_native is a package.preload stub, and
-- package.loadlib a spy that records what it was asked to load.
-- Usage, from the repository root: lua tests/test_z3_loader.lua

-- The stubs replace io and fields of package, which luacheck treats as
-- read-only.
-- luacheck: ignore 121 122

local WINDOWS_CONFIG = "\\\n;\n?\n!\n-\n"
local POSIX_CONFIG = "/\n;\n?\n!\n-\n"

local saved = {
  config = package.config,
  cpath = package.cpath,
  loadlib = package.loadlib,
  searchpath = package.searchpath,
  preload = package.preload.z3_native,
  loaded = package.loaded.z3_native,
  io = io,
}

local native_stub = {}
local loads

local function restore()
  package.config = saved.config
  package.cpath = saved.cpath
  package.loadlib = saved.loadlib
  package.searchpath = saved.searchpath
  package.preload.z3_native = saved.preload
  package.loaded.z3_native = saved.loaded
  io = saved.io
end

-- Runs rock/z3.lua with the given package.config, package.cpath and
-- package.searchpath, and returns what it returned. `sandboxed` withholds
-- package.loadlib and makes any use of io raise, as a sandbox that removes
-- both would.
local function load_wrapper(config, cpath, searchpath, sandboxed)
  loads = {}
  package.config = config
  package.cpath = cpath
  package.searchpath = searchpath
  if sandboxed then
    package.loadlib = nil
    io = setmetatable({}, {__index = function(_, key)
      error("io." .. tostring(key) .. " used in a sandbox", 2)
    end})
  else
    package.loadlib = function(path, symbol)
      loads[#loads + 1] = {path = path, symbol = symbol}
      return nil, "spy", "open"
    end
  end
  package.preload.z3_native = function() return native_stub end
  package.loaded.z3_native = nil
  local ok, result = pcall(dofile, "rock/z3.lua")
  restore()
  assert(ok, result)
  return result
end

-- A C runtime older than the UCRT answers a name in the root of the current
-- drive, such as "\s1v0.", which is moved into the temporary directory.
local temp_base = os.tmpname()
if not temp_base:find("[/\\]", 2) then
  local temp_root = os.getenv("TEMP") or os.getenv("TMPDIR") or "."
  temp_base = temp_root .. "/" .. temp_base:gsub("^[/\\]", "")
end
local native_file = temp_base .. "_z3_native.dll"
local temp_dir = native_file:match("(.+)[/\\]")
local missing_dir = temp_base .. "_missing"
local found_cpath = missing_dir .. "/?.dll;" .. temp_base .. "_?.dll"

local function cleanup()
  os.remove(native_file)
  os.remove(temp_base)
end

local file, open_error = io.open(native_file, "w")
if not file then
  cleanup()
  error(open_error)
end
file:close()

local tests = {}

tests["without package.searchpath, finds z3_native and loads libz3 by an "
    .. "exported symbol"] = function()
  local result = load_wrapper(WINDOWS_CONFIG, found_cpath, nil)
  assert(result == native_stub, "z3.lua must return z3_native's module")
  assert(#loads == 1, "expected one loadlib call, got " .. #loads)
  assert(loads[1].path == temp_dir .. "/libz3.dll", loads[1].path)
  assert(loads[1].symbol == "Z3_get_full_version", loads[1].symbol)
end

if saved.searchpath then
  tests["with package.searchpath, loads libz3 with \"*\""] = function()
    local result = load_wrapper(WINDOWS_CONFIG, found_cpath, saved.searchpath)
    assert(result == native_stub, "z3.lua must return z3_native's module")
    assert(#loads == 1, "expected one loadlib call, got " .. #loads)
    assert(loads[1].path == temp_dir .. "/libz3.dll", loads[1].path)
    assert(loads[1].symbol == "*", loads[1].symbol)
  end
end

tests["without package.searchpath, a z3_native missing from cpath loads "
    .. "nothing"] = function()
  local result = load_wrapper(WINDOWS_CONFIG, missing_dir .. "/?.dll", nil)
  assert(result == native_stub, "z3.lua must return z3_native's module")
  assert(#loads == 0, "expected no loadlib call, got " .. #loads)
end

tests["without package.loadlib, searches and loads nothing"] = function()
  local result = load_wrapper(WINDOWS_CONFIG, found_cpath, nil, true)
  assert(result == native_stub, "z3.lua must return z3_native's module")
  assert(#loads == 0, "expected no loadlib call, got " .. #loads)
end

tests["off Windows, loads nothing"] = function()
  local result = load_wrapper(POSIX_CONFIG, found_cpath, saved.searchpath)
  assert(result == native_stub, "z3.lua must return z3_native's module")
  assert(#loads == 0, "expected no loadlib call, got " .. #loads)
end

local names = {}
for name in pairs(tests) do
  names[#names + 1] = name
end
table.sort(names)

local failures = 0
for _, name in ipairs(names) do
  local ok, err = pcall(tests[name])
  if ok then
    print("PASS " .. name)
  else
    failures = failures + 1
    print("FAIL " .. name .. ": " .. tostring(err))
  end
end
cleanup()

print(string.format("%s: %d passed, %d failed", _VERSION,
                    #names - failures, failures))
if failures > 0 then
  os.exit(1)
end
