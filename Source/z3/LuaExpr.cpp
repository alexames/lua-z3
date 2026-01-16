#include "z3/LuaExpr.hpp"

static z3::expr* checkExpr(lua_State* L, int index) {
  return luaW_check<z3::expr>(L, index);
}

// Get the sort of this expression
static int Expr_get_sort(lua_State* L) {
  auto* expr = checkExpr(L, 1);
  auto* sort = new z3::sort(expr->get_sort());
  luaW_push<z3::sort>(L, sort);
  return 1;
}

// Check if expression is of a particular kind
static int Expr_is_bool(lua_State* L) {
  auto* expr = checkExpr(L, 1);
  lua_pushboolean(L, expr->is_bool());
  return 1;
}

static int Expr_is_int(lua_State* L) {
  auto* expr = checkExpr(L, 1);
  lua_pushboolean(L, expr->is_int());
  return 1;
}

static int Expr_is_real(lua_State* L) {
  auto* expr = checkExpr(L, 1);
  lua_pushboolean(L, expr->is_real());
  return 1;
}

static int Expr_is_arith(lua_State* L) {
  auto* expr = checkExpr(L, 1);
  lua_pushboolean(L, expr->is_arith());
  return 1;
}

static int Expr_is_bv(lua_State* L) {
  auto* expr = checkExpr(L, 1);
  lua_pushboolean(L, expr->is_bv());
  return 1;
}

static int Expr_is_const(lua_State* L) {
  auto* expr = checkExpr(L, 1);
  lua_pushboolean(L, expr->is_const());
  return 1;
}

// Simplify expression
static int Expr_simplify(lua_State* L) {
  auto* expr = checkExpr(L, 1);
  auto* result = new z3::expr(expr->simplify());
  luaW_push<z3::expr>(L, result);
  return 1;
}

// Substitute variables
static int Expr_substitute(lua_State* L) {
  auto* expr = checkExpr(L, 1);
  auto* from = luaW_check<z3::expr>(L, 2);
  auto* to = luaW_check<z3::expr>(L, 3);
  z3::expr_vector from_vec(from->ctx());
  z3::expr_vector to_vec(from->ctx());
  from_vec.push_back(*from);
  to_vec.push_back(*to);
  auto* result = new z3::expr(expr->substitute(from_vec, to_vec));
  luaW_push<z3::expr>(L, result);
  return 1;
}

// Arithmetic operations
static int Expr_add(lua_State* L) {
  auto* a = checkExpr(L, 1);
  if (lua_isnumber(L, 2)) {
    lua_Integer val = luaL_checkinteger(L, 2);
    auto* result = new z3::expr(*a + static_cast<int>(val));
    luaW_push<z3::expr>(L, result);
  } else {
    auto* b = checkExpr(L, 2);
    auto* result = new z3::expr(*a + *b);
    luaW_push<z3::expr>(L, result);
  }
  return 1;
}

static int Expr_sub(lua_State* L) {
  auto* a = checkExpr(L, 1);
  if (lua_isnumber(L, 2)) {
    lua_Integer val = luaL_checkinteger(L, 2);
    auto* result = new z3::expr(*a - static_cast<int>(val));
    luaW_push<z3::expr>(L, result);
  } else {
    auto* b = checkExpr(L, 2);
    auto* result = new z3::expr(*a - *b);
    luaW_push<z3::expr>(L, result);
  }
  return 1;
}

static int Expr_mul(lua_State* L) {
  auto* a = checkExpr(L, 1);
  if (lua_isnumber(L, 2)) {
    lua_Integer val = luaL_checkinteger(L, 2);
    auto* result = new z3::expr(*a * static_cast<int>(val));
    luaW_push<z3::expr>(L, result);
  } else {
    auto* b = checkExpr(L, 2);
    auto* result = new z3::expr(*a * *b);
    luaW_push<z3::expr>(L, result);
  }
  return 1;
}

static int Expr_div(lua_State* L) {
  auto* a = checkExpr(L, 1);
  if (lua_isnumber(L, 2)) {
    lua_Integer val = luaL_checkinteger(L, 2);
    auto* result = new z3::expr(*a / static_cast<int>(val));
    luaW_push<z3::expr>(L, result);
  } else {
    auto* b = checkExpr(L, 2);
    auto* result = new z3::expr(*a / *b);
    luaW_push<z3::expr>(L, result);
  }
  return 1;
}

static int Expr_mod(lua_State* L) {
  auto* a = checkExpr(L, 1);
  auto* b = checkExpr(L, 2);
  auto* result = new z3::expr(z3::mod(*a, *b));
  luaW_push<z3::expr>(L, result);
  return 1;
}

static int Expr_unm(lua_State* L) {
  auto* a = checkExpr(L, 1);
  auto* result = new z3::expr(-(*a));
  luaW_push<z3::expr>(L, result);
  return 1;
}

static int Expr_pow(lua_State* L) {
  auto* a = checkExpr(L, 1);
  auto* b = checkExpr(L, 2);
  auto* result = new z3::expr(z3::pw(*a, *b));
  luaW_push<z3::expr>(L, result);
  return 1;
}

// Comparison operations (return expressions, not booleans!)
static int Expr_eq(lua_State* L) {
  auto* a = checkExpr(L, 1);
  auto* b = checkExpr(L, 2);
  auto* result = new z3::expr(*a == *b);
  luaW_push<z3::expr>(L, result);
  return 1;
}

static int Expr_ne(lua_State* L) {
  auto* a = checkExpr(L, 1);
  auto* b = checkExpr(L, 2);
  auto* result = new z3::expr(*a != *b);
  luaW_push<z3::expr>(L, result);
  return 1;
}

static int Expr_lt(lua_State* L) {
  auto* a = checkExpr(L, 1);
  auto* b = checkExpr(L, 2);
  auto* result = new z3::expr(*a < *b);
  luaW_push<z3::expr>(L, result);
  return 1;
}

static int Expr_le(lua_State* L) {
  auto* a = checkExpr(L, 1);
  auto* b = checkExpr(L, 2);
  auto* result = new z3::expr(*a <= *b);
  luaW_push<z3::expr>(L, result);
  return 1;
}

static int Expr_gt(lua_State* L) {
  auto* a = checkExpr(L, 1);
  auto* b = checkExpr(L, 2);
  auto* result = new z3::expr(*a > *b);
  luaW_push<z3::expr>(L, result);
  return 1;
}

static int Expr_ge(lua_State* L) {
  auto* a = checkExpr(L, 1);
  auto* b = checkExpr(L, 2);
  auto* result = new z3::expr(*a >= *b);
  luaW_push<z3::expr>(L, result);
  return 1;
}

// Logical operations
static int Expr_land(lua_State* L) {
  auto* a = checkExpr(L, 1);
  auto* b = checkExpr(L, 2);
  auto* result = new z3::expr(*a && *b);
  luaW_push<z3::expr>(L, result);
  return 1;
}

static int Expr_lor(lua_State* L) {
  auto* a = checkExpr(L, 1);
  auto* b = checkExpr(L, 2);
  auto* result = new z3::expr(*a || *b);
  luaW_push<z3::expr>(L, result);
  return 1;
}

static int Expr_lnot(lua_State* L) {
  auto* a = checkExpr(L, 1);
  auto* result = new z3::expr(!(*a));
  luaW_push<z3::expr>(L, result);
  return 1;
}

static int Expr_implies(lua_State* L) {
  auto* a = checkExpr(L, 1);
  auto* b = checkExpr(L, 2);
  auto* result = new z3::expr(z3::implies(*a, *b));
  luaW_push<z3::expr>(L, result);
  return 1;
}

static int Expr_ite(lua_State* L) {
  auto* cond = checkExpr(L, 1);
  auto* then_expr = checkExpr(L, 2);
  auto* else_expr = checkExpr(L, 3);
  auto* result = new z3::expr(z3::ite(*cond, *then_expr, *else_expr));
  luaW_push<z3::expr>(L, result);
  return 1;
}

// Bitvector operations
static int Expr_bvand(lua_State* L) {
  auto* a = checkExpr(L, 1);
  auto* b = checkExpr(L, 2);
  auto* result = new z3::expr(*a & *b);
  luaW_push<z3::expr>(L, result);
  return 1;
}

static int Expr_bvor(lua_State* L) {
  auto* a = checkExpr(L, 1);
  auto* b = checkExpr(L, 2);
  auto* result = new z3::expr(*a | *b);
  luaW_push<z3::expr>(L, result);
  return 1;
}

static int Expr_bvxor(lua_State* L) {
  auto* a = checkExpr(L, 1);
  auto* b = checkExpr(L, 2);
  auto* result = new z3::expr(*a ^ *b);
  luaW_push<z3::expr>(L, result);
  return 1;
}

static int Expr_bvnot(lua_State* L) {
  auto* a = checkExpr(L, 1);
  auto* result = new z3::expr(~(*a));
  luaW_push<z3::expr>(L, result);
  return 1;
}

static int Expr_bvshl(lua_State* L) {
  auto* a = checkExpr(L, 1);
  auto* b = checkExpr(L, 2);
  auto* result = new z3::expr(z3::shl(*a, *b));
  luaW_push<z3::expr>(L, result);
  return 1;
}

static int Expr_bvshr(lua_State* L) {
  auto* a = checkExpr(L, 1);
  auto* b = checkExpr(L, 2);
  auto* result = new z3::expr(z3::lshr(*a, *b));
  luaW_push<z3::expr>(L, result);
  return 1;
}

static int Expr_bvashr(lua_State* L) {
  auto* a = checkExpr(L, 1);
  auto* b = checkExpr(L, 2);
  auto* result = new z3::expr(z3::ashr(*a, *b));
  luaW_push<z3::expr>(L, result);
  return 1;
}

// Extract bits from bitvector
static int Expr_extract(lua_State* L) {
  auto* a = checkExpr(L, 1);
  unsigned high = static_cast<unsigned>(luaL_checkinteger(L, 2));
  unsigned low = static_cast<unsigned>(luaL_checkinteger(L, 3));
  auto* result = new z3::expr(a->extract(high, low));
  luaW_push<z3::expr>(L, result);
  return 1;
}

// Concatenate bitvectors
static int Expr_concat(lua_State* L) {
  auto* a = checkExpr(L, 1);
  auto* b = checkExpr(L, 2);
  auto* result = new z3::expr(z3::concat(*a, *b));
  luaW_push<z3::expr>(L, result);
  return 1;
}

static int Expr_tostring(lua_State* L) {
  auto* expr = checkExpr(L, 1);
  lua_pushstring(L, expr->to_string().c_str());
  return 1;
}

// No standalone allocator - expressions are created from context
static void Expr_deallocator(lua_State* L, z3::expr* expr) {
  delete expr;
}

static luaL_Reg exprTable[] = {
    {NULL, NULL}
};

static luaL_Reg exprMetatable[] = {
    // Type queries
    {"get_sort", Expr_get_sort},
    {"is_bool", Expr_is_bool},
    {"is_int", Expr_is_int},
    {"is_real", Expr_is_real},
    {"is_arith", Expr_is_arith},
    {"is_bv", Expr_is_bv},
    {"is_const", Expr_is_const},
    // Transformations
    {"simplify", Expr_simplify},
    {"substitute", Expr_substitute},
    // Arithmetic metamethods
    {"__add", Expr_add},
    {"__sub", Expr_sub},
    {"__mul", Expr_mul},
    {"__div", Expr_div},
    {"__mod", Expr_mod},
    {"__unm", Expr_unm},
    {"__pow", Expr_pow},
    // Comparison (return z3 expressions)
    {"eq", Expr_eq},
    {"ne", Expr_ne},
    {"lt", Expr_lt},
    {"le", Expr_le},
    {"gt", Expr_gt},
    {"ge", Expr_ge},
    // Logical operations
    {"land", Expr_land},
    {"lor", Expr_lor},
    {"lnot", Expr_lnot},
    {"implies", Expr_implies},
    {"ite", Expr_ite},
    // Bitvector operations
    {"bvand", Expr_bvand},
    {"bvor", Expr_bvor},
    {"bvxor", Expr_bvxor},
    {"bvnot", Expr_bvnot},
    {"bvshl", Expr_bvshl},
    {"bvshr", Expr_bvshr},
    {"bvashr", Expr_bvashr},
    {"extract", Expr_extract},
    {"concat", Expr_concat},
    // String representation
    {"__tostring", Expr_tostring},
    {NULL, NULL}
};

int luaopen_z3_expr(lua_State* L) {
  luaW_register<z3::expr>(
      L,
      "z3.expr",
      exprTable,
      exprMetatable,
      nullptr,
      Expr_deallocator
  );
  return 1;
}
