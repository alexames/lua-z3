-- z3.lua: Wrapper module for lua-z3.
--
-- The binary rock installs the C module as z3_native so that require("z3")
-- resolves to this Lua file first.
--
-- On Windows, z3_native.dll may depend on libz3.dll at runtime. The
-- standard DLL search order does NOT include the directory containing the
-- loading DLL, so libz3.dll must be explicitly preloaded before
-- z3_native.dll is required.
--
-- Runs on Lua 5.1 through 5.5 and LuaJIT. Stock Lua 5.1 lacks two Lua 5.2
-- additions that LuaJIT has: package.searchpath, and package.loadlib's "*",
-- which links a library without looking up a symbol in it.

local dirsep, pathsep, mark = package.config:match("^(.-)\n(.-)\n(.-)\n")

local function escape_pattern(text)
  return (text:gsub("%p", "%%%0"))
end

-- package.searchpath where present, else the same search in Lua: the first
-- template in `path` that, with each `mark` replaced by `name`, names a file
-- that can be opened for reading.
local function search_path(name, path)
  if package.searchpath then
    return package.searchpath(name, path)
  end
  local file_name = name:gsub("%.", dirsep):gsub("%%", "%%%%")
  local mark_pattern = escape_pattern(mark)
  for template in path:gmatch("[^" .. escape_pattern(pathsep) .. "]+") do
    local candidate = template:gsub(mark_pattern, file_name)
    local file = io.open(candidate, "r")
    if file then
      file:close()
      return candidate
    end
  end
  return nil
end

-- Lua 5.1's loadlib keeps a library it loaded even when the symbol lookup
-- fails, but then reports failure, so it is given a symbol libz3 exports.
-- package.searchpath arrived with "*" in 5.2, and LuaJIT has both, so its
-- absence marks a loadlib without "*".
local link_symbol = package.searchpath and "*" or "Z3_get_full_version"

-- A host that withholds loadlib from its scripts, as a sandbox does, may also
-- withhold io, which the search can need; its z3_native loads only if libz3
-- is in the process already, so nothing is preloaded there.
if dirsep == "\\" and package.loadlib then
  local native_path = search_path("z3_native", package.cpath)
  local dir = native_path and native_path:match("(.+)[/\\]")
  if dir then
    -- Fails when libz3 is statically linked into z3_native, which needs
    -- nothing preloaded.
    package.loadlib(dir .. "/libz3.dll", link_symbol)
  end
end

return require("z3_native")
