-- z3.lua: Preloader wrapper for the lua-z3 binary rock.
--
-- On Windows, z3_native.dll depends on libz3.dll at runtime. The standard
-- Windows DLL search order does NOT include the directory containing the
-- loading DLL, so libz3.dll must be explicitly preloaded before
-- z3_native.dll is required.
--
-- package.loadlib(path, "*") loads a DLL into the process without calling
-- any entry point, making it available as a dependency for subsequent loads.

local sep = package.config:sub(1, 1) -- "/" or "\"

-- Find the directory containing z3_native.dll using the C module search path.
local native_path = package.searchpath("z3_native", package.cpath)
if native_path then
  local dir = native_path:match("(.*)" .. (sep == "\\" and "\\\\" or sep))
  if dir then
    local libz3_path = dir .. sep .. "libz3.dll"
    -- Preload libz3.dll so it is available when z3_native.dll is loaded.
    -- The "*" sentinel loads the library without calling a Lua entry point.
    package.loadlib(libz3_path, "*")
  end
end

return require("z3_native")
