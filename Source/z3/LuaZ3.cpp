#include "z3/Lua.hpp"
#include "z3/LuaContext.hpp"
#include "z3/LuaSolver.hpp"
#include "z3/LuaExpr.hpp"
#include "z3/LuaSort.hpp"
#include "z3/LuaModel.hpp"

// Helper functions for creating expressions from Lua values
static int z3_And(lua_State* L) {
  int n = lua_gettop(L);
  if (n < 2) {
    return luaL_error(L, "z3.And requires at least 2 arguments");
  }
  auto* first = luaW_check<z3::expr>(L, 1);
  z3::expr result = *first;
  for (int i = 2; i <= n; ++i) {
    auto* expr = luaW_check<z3::expr>(L, i);
    result = result && *expr;
  }
  auto* res = new z3::expr(result);
  luaW_push<z3::expr>(L, res);
  return 1;
}

static int z3_Or(lua_State* L) {
  int n = lua_gettop(L);
  if (n < 2) {
    return luaL_error(L, "z3.Or requires at least 2 arguments");
  }
  auto* first = luaW_check<z3::expr>(L, 1);
  z3::expr result = *first;
  for (int i = 2; i <= n; ++i) {
    auto* expr = luaW_check<z3::expr>(L, i);
    result = result || *expr;
  }
  auto* res = new z3::expr(result);
  luaW_push<z3::expr>(L, res);
  return 1;
}

static int z3_Not(lua_State* L) {
  auto* expr = luaW_check<z3::expr>(L, 1);
  auto* result = new z3::expr(!(*expr));
  luaW_push<z3::expr>(L, result);
  return 1;
}

static int z3_Implies(lua_State* L) {
  auto* a = luaW_check<z3::expr>(L, 1);
  auto* b = luaW_check<z3::expr>(L, 2);
  auto* result = new z3::expr(z3::implies(*a, *b));
  luaW_push<z3::expr>(L, result);
  return 1;
}

static int z3_Ite(lua_State* L) {
  auto* cond = luaW_check<z3::expr>(L, 1);
  auto* then_expr = luaW_check<z3::expr>(L, 2);
  auto* else_expr = luaW_check<z3::expr>(L, 3);
  auto* result = new z3::expr(z3::ite(*cond, *then_expr, *else_expr));
  luaW_push<z3::expr>(L, result);
  return 1;
}

static int z3_Distinct(lua_State* L) {
  int n = lua_gettop(L);
  if (n < 2) {
    return luaL_error(L, "z3.Distinct requires at least 2 arguments");
  }
  auto* first = luaW_check<z3::expr>(L, 1);
  z3::expr_vector vec(first->ctx());
  for (int i = 1; i <= n; ++i) {
    auto* expr = luaW_check<z3::expr>(L, i);
    vec.push_back(*expr);
  }
  auto* result = new z3::expr(z3::distinct(vec));
  luaW_push<z3::expr>(L, result);
  return 1;
}

// Arithmetic helpers
static int z3_Sum(lua_State* L) {
  int n = lua_gettop(L);
  if (n < 1) {
    return luaL_error(L, "z3.Sum requires at least 1 argument");
  }
  auto* first = luaW_check<z3::expr>(L, 1);
  z3::expr result = *first;
  for (int i = 2; i <= n; ++i) {
    auto* expr = luaW_check<z3::expr>(L, i);
    result = result + *expr;
  }
  auto* res = new z3::expr(result);
  luaW_push<z3::expr>(L, res);
  return 1;
}

static int z3_Product(lua_State* L) {
  int n = lua_gettop(L);
  if (n < 1) {
    return luaL_error(L, "z3.Product requires at least 1 argument");
  }
  auto* first = luaW_check<z3::expr>(L, 1);
  z3::expr result = *first;
  for (int i = 2; i <= n; ++i) {
    auto* expr = luaW_check<z3::expr>(L, i);
    result = result * *expr;
  }
  auto* res = new z3::expr(result);
  luaW_push<z3::expr>(L, res);
  return 1;
}

// Module-level functions
static luaL_Reg z3Functions[] = {
    {"And", z3_And},
    {"Or", z3_Or},
    {"Not", z3_Not},
    {"Implies", z3_Implies},
    {"Ite", z3_Ite},
    {"Distinct", z3_Distinct},
    {"Sum", z3_Sum},
    {"Product", z3_Product},
    {NULL, NULL}
};

extern "C" {

#ifdef _WIN32
__declspec(dllexport)
#endif
int luaopen_z3(lua_State* L) {
  // Register all types first
  luaopen_z3_context(L);
  luaopen_z3_solver(L);
  luaopen_z3_expr(L);
  luaopen_z3_sort(L);
  luaopen_z3_model(L);

  // Create the z3 module table
  lua_newtable(L);

  // Add the Context constructor
  luaW_getregistry<z3::context>(L, "z3.context");
  lua_setfield(L, -2, "Context");

  // Add the Solver constructor
  luaW_getregistry<z3::solver>(L, "z3.solver");
  lua_setfield(L, -2, "Solver");

  // Add module-level functions
  luaL_setfuncs(L, z3Functions, 0);

  return 1;
}

}  // extern "C"
