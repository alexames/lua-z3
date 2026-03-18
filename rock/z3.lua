-- z3.lua: Wrapper module for lua-z3.
--
-- The binary rock installs the C module as z3_native so that require("z3")
-- resolves to this Lua file first.  Z3 is statically linked into the C
-- module, so no runtime DLL preloading is needed.

return require("z3_native")
