package = "lua-z3"
version = "0.1.0-1"

source = {
   url = "git+https://github.com/alexames/lua-z3.git",
   tag = "v0.1.0"
}

description = {
   summary = "Lua bindings for the Z3 theorem prover",
   detailed = [[
      lua-z3 provides Lua 5.4 bindings for the Z3 theorem prover,
      allowing you to use Z3's powerful SMT solving capabilities
      directly from Lua code.
   ]],
   homepage = "https://github.com/alexames/lua-z3",
   license = "MIT"
}

dependencies = {
   "lua >= 5.4"
}

external_dependencies = {
   Z3 = {
      header = "z3.h",
      library = "z3"
   }
}

build = {
   type = "cmake",
   variables = {
      CMAKE_INSTALL_PREFIX = "$(PREFIX)",
      LUA_INCLUDE_DIR = "$(LUA_INCDIR)",
      LUA_LIBRARIES = "$(LUA_LIBDIR)/$(LUALIB)",
      Z3_INCLUDE_DIR = "$(Z3_INCDIR)",
      Z3_LIBRARY = "$(Z3_LIBDIR)/$(Z3_LIBNAME)",
   }
}
