#ifndef LUA_Z3_LUA_HPP_
#define LUA_Z3_LUA_HPP_

#include "luawrapper.hpp"
#include "luawrapperutil.hpp"
extern "C" {
#include "lauxlib.h"
#include "lua.h"
#include "luaconf.h"
#include "lualib.h"
}

// Compatibility shims for older Lua versions
#if LUA_VERSION_NUM < 502
// luaL_setfuncs was introduced in Lua 5.2.
inline void luaL_setfuncs(lua_State* L, const luaL_Reg* l, int nup) {
  for (; l->name != NULL; l++) {
    for (int i = 0; i < nup; i++)
      lua_pushvalue(L, -nup);
    lua_pushcclosure(L, l->func, nup);
    lua_setfield(L, -(nup + 2), l->name);
  }
  lua_pop(L, nup);
}
#endif

#if LUA_VERSION_NUM < 503
// lua_isinteger was introduced in Lua 5.3. In older versions, all numbers are
// floats, so we fall back to checking if the value is a number.
#define lua_isinteger(L, idx) (lua_type(L, idx) == LUA_TNUMBER)
#endif

// In Lua 5.3+, modules return a table from luaopen_* and globals are
// discouraged (some hosts lock the global table).  luaW_setfuncs registers
// the type's metatable and leaves the type table on the stack without
// writing a global.  luaW_register does the same but also calls
// lua_setglobal, which is the expected pattern for Lua 5.1/5.2.
#if LUA_VERSION_NUM >= 503
#define LUAZ3_REGISTER_TYPE luaW_setfuncs
#else
#define LUAZ3_REGISTER_TYPE luaW_register
#endif

#include <z3++.h>

#endif  // LUA_Z3_LUA_HPP_
