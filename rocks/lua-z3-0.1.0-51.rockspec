package = "lua-z3"
version = "0.1.0-51"

source = {
   url = "git+https://github.com/alexames/lua-z3.git",
   tag = "v0.1.0"
}

description = {
   summary = "Lua bindings for the Z3 theorem prover",
   detailed = [[
      lua-z3 provides Lua bindings for the Z3 theorem prover,
      allowing you to use Z3's powerful SMT solving capabilities
      directly from Lua code.
   ]],
   homepage = "https://github.com/alexames/lua-z3",
   license = "MIT"
}

dependencies = {
   "lua >= 5.1, < 5.2"
}

build = {
   type = "builtin",
   modules = {}
}
