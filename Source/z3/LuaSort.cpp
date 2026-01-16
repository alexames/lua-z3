#include "z3/LuaSort.hpp"

static z3::sort* checkSort(lua_State* L, int index) {
  return luaW_check<z3::sort>(L, index);
}

static int Sort_is_bool(lua_State* L) {
  auto* sort = checkSort(L, 1);
  lua_pushboolean(L, sort->is_bool());
  return 1;
}

static int Sort_is_int(lua_State* L) {
  auto* sort = checkSort(L, 1);
  lua_pushboolean(L, sort->is_int());
  return 1;
}

static int Sort_is_real(lua_State* L) {
  auto* sort = checkSort(L, 1);
  lua_pushboolean(L, sort->is_real());
  return 1;
}

static int Sort_is_arith(lua_State* L) {
  auto* sort = checkSort(L, 1);
  lua_pushboolean(L, sort->is_arith());
  return 1;
}

static int Sort_is_bv(lua_State* L) {
  auto* sort = checkSort(L, 1);
  lua_pushboolean(L, sort->is_bv());
  return 1;
}

static int Sort_is_array(lua_State* L) {
  auto* sort = checkSort(L, 1);
  lua_pushboolean(L, sort->is_array());
  return 1;
}

static int Sort_is_datatype(lua_State* L) {
  auto* sort = checkSort(L, 1);
  lua_pushboolean(L, sort->is_datatype());
  return 1;
}

static int Sort_is_finite_domain(lua_State* L) {
  auto* sort = checkSort(L, 1);
  lua_pushboolean(L, sort->is_finite_domain());
  return 1;
}

static int Sort_bv_size(lua_State* L) {
  auto* sort = checkSort(L, 1);
  if (!sort->is_bv()) {
    return luaL_error(L, "sort is not a bitvector");
  }
  lua_pushinteger(L, sort->bv_size());
  return 1;
}

static int Sort_name(lua_State* L) {
  auto* sort = checkSort(L, 1);
  lua_pushstring(L, sort->name().str().c_str());
  return 1;
}

static int Sort_tostring(lua_State* L) {
  auto* sort = checkSort(L, 1);
  lua_pushstring(L, sort->to_string().c_str());
  return 1;
}

static void Sort_deallocator(lua_State* L, z3::sort* sort) {
  delete sort;
}

static luaL_Reg sortTable[] = {
    {NULL, NULL}
};

static luaL_Reg sortMetatable[] = {
    {"is_bool", Sort_is_bool},
    {"is_int", Sort_is_int},
    {"is_real", Sort_is_real},
    {"is_arith", Sort_is_arith},
    {"is_bv", Sort_is_bv},
    {"is_array", Sort_is_array},
    {"is_datatype", Sort_is_datatype},
    {"is_finite_domain", Sort_is_finite_domain},
    {"bv_size", Sort_bv_size},
    {"name", Sort_name},
    {"__tostring", Sort_tostring},
    {NULL, NULL}
};

int luaopen_z3_sort(lua_State* L) {
  luaW_register<z3::sort>(
      L,
      "z3.sort",
      sortTable,
      sortMetatable,
      nullptr,
      Sort_deallocator
  );
  return 1;
}
