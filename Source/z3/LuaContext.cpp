#include "z3/LuaContext.hpp"

// Helper to get a context pointer from the Lua stack
static z3::context* checkContext(lua_State* L, int index) {
  return luaW_check<z3::context>(L, index);
}

// Context methods

static int Context_bool_const(lua_State* L) {
  auto* ctx = checkContext(L, 1);
  const char* name = luaL_checkstring(L, 2);
  auto* expr = new z3::expr(ctx->bool_const(name));
  luaW_push<z3::expr>(L, expr);
  return 1;
}

static int Context_int_const(lua_State* L) {
  auto* ctx = checkContext(L, 1);
  const char* name = luaL_checkstring(L, 2);
  auto* expr = new z3::expr(ctx->int_const(name));
  luaW_push<z3::expr>(L, expr);
  return 1;
}

static int Context_real_const(lua_State* L) {
  auto* ctx = checkContext(L, 1);
  const char* name = luaL_checkstring(L, 2);
  auto* expr = new z3::expr(ctx->real_const(name));
  luaW_push<z3::expr>(L, expr);
  return 1;
}

static int Context_bv_const(lua_State* L) {
  auto* ctx = checkContext(L, 1);
  const char* name = luaL_checkstring(L, 2);
  unsigned sz = static_cast<unsigned>(luaL_checkinteger(L, 3));
  auto* expr = new z3::expr(ctx->bv_const(name, sz));
  luaW_push<z3::expr>(L, expr);
  return 1;
}

static int Context_string_const(lua_State* L) {
  auto* ctx = checkContext(L, 1);
  const char* name = luaL_checkstring(L, 2);
  auto* expr = new z3::expr(ctx->string_const(name));
  luaW_push<z3::expr>(L, expr);
  return 1;
}

// Sort creation methods

static int Context_bool_sort(lua_State* L) {
  auto* ctx = checkContext(L, 1);
  auto* sort = new z3::sort(ctx->bool_sort());
  luaW_push<z3::sort>(L, sort);
  return 1;
}

static int Context_int_sort(lua_State* L) {
  auto* ctx = checkContext(L, 1);
  auto* sort = new z3::sort(ctx->int_sort());
  luaW_push<z3::sort>(L, sort);
  return 1;
}

static int Context_real_sort(lua_State* L) {
  auto* ctx = checkContext(L, 1);
  auto* sort = new z3::sort(ctx->real_sort());
  luaW_push<z3::sort>(L, sort);
  return 1;
}

static int Context_bv_sort(lua_State* L) {
  auto* ctx = checkContext(L, 1);
  unsigned sz = static_cast<unsigned>(luaL_checkinteger(L, 2));
  auto* sort = new z3::sort(ctx->bv_sort(sz));
  luaW_push<z3::sort>(L, sort);
  return 1;
}

static int Context_string_sort(lua_State* L) {
  auto* ctx = checkContext(L, 1);
  auto* sort = new z3::sort(ctx->string_sort());
  luaW_push<z3::sort>(L, sort);
  return 1;
}

// Literal value creation

static int Context_bool_val(lua_State* L) {
  auto* ctx = checkContext(L, 1);
  bool val = lua_toboolean(L, 2);
  auto* expr = new z3::expr(ctx->bool_val(val));
  luaW_push<z3::expr>(L, expr);
  return 1;
}

static int Context_int_val(lua_State* L) {
  auto* ctx = checkContext(L, 1);
  lua_Integer val = luaL_checkinteger(L, 2);
  auto* expr = new z3::expr(ctx->int_val(static_cast<int64_t>(val)));
  luaW_push<z3::expr>(L, expr);
  return 1;
}

static int Context_real_val(lua_State* L) {
  auto* ctx = checkContext(L, 1);
  if (lua_isinteger(L, 2)) {
    lua_Integer num = luaL_checkinteger(L, 2);
    lua_Integer den = luaL_optinteger(L, 3, 1);
    auto* expr = new z3::expr(ctx->real_val(static_cast<int>(num), static_cast<int>(den)));
    luaW_push<z3::expr>(L, expr);
  } else {
    const char* val = luaL_checkstring(L, 2);
    auto* expr = new z3::expr(ctx->real_val(val));
    luaW_push<z3::expr>(L, expr);
  }
  return 1;
}

static int Context_bv_val(lua_State* L) {
  auto* ctx = checkContext(L, 1);
  lua_Integer val = luaL_checkinteger(L, 2);
  unsigned sz = static_cast<unsigned>(luaL_checkinteger(L, 3));
  auto* expr = new z3::expr(ctx->bv_val(static_cast<int64_t>(val), sz));
  luaW_push<z3::expr>(L, expr);
  return 1;
}

static int Context_string_val(lua_State* L) {
  auto* ctx = checkContext(L, 1);
  const char* val = luaL_checkstring(L, 2);
  auto* expr = new z3::expr(ctx->string_val(val));
  luaW_push<z3::expr>(L, expr);
  return 1;
}

// Allocator for creating new context objects
static z3::context* Context_allocator(lua_State* L) {
  return new z3::context();
}

// Deallocator
static void Context_deallocator(lua_State* L, z3::context* ctx) {
  delete ctx;
}

static int Context_tostring(lua_State* L) {
  lua_pushstring(L, "z3.context");
  return 1;
}

// Table of static functions (called on z3.Context)
static luaL_Reg contextTable[] = {
    {NULL, NULL}
};

// Table of instance methods (called on context objects)
static luaL_Reg contextMetatable[] = {
    // Variable creation
    {"bool_const", Context_bool_const},
    {"int_const", Context_int_const},
    {"real_const", Context_real_const},
    {"bv_const", Context_bv_const},
    {"string_const", Context_string_const},
    // Sort creation
    {"bool_sort", Context_bool_sort},
    {"int_sort", Context_int_sort},
    {"real_sort", Context_real_sort},
    {"bv_sort", Context_bv_sort},
    {"string_sort", Context_string_sort},
    // Literal values
    {"bool_val", Context_bool_val},
    {"int_val", Context_int_val},
    {"real_val", Context_real_val},
    {"bv_val", Context_bv_val},
    {"string_val", Context_string_val},
    // Metamethods
    {"__tostring", Context_tostring},
    {NULL, NULL}
};

int luaopen_z3_context(lua_State* L) {
  luaW_register<z3::context>(
      L,
      "z3.context",
      contextTable,
      contextMetatable,
      Context_allocator,
      Context_deallocator
  );
  return 1;
}
