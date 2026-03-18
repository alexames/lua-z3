-- z3.lua: Wrapper module for lua-z3.
--
-- The binary rock installs the C module as z3_native so that require("z3")
-- resolves to this Lua file first.
--
-- On Windows, z3_native.dll may depend on libz3.dll at runtime. The
-- standard DLL search order does NOT include the directory containing the
-- loading DLL, so libz3.dll must be explicitly preloaded before
-- z3_native.dll is required.

if package.config:sub(1, 1) == "\\" then
  local native_path = package.searchpath("z3_native", package.cpath)
  if native_path then
    local dir = native_path:match("(.+)[/\\]")
    if dir then
      local ok = package.loadlib(dir .. "/libz3.dll", "*")
      if not ok then
        -- libz3 may be statically linked; ignore and continue.
      end
    end
  end
end

return require("z3_native")
