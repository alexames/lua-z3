#include "z3/LuaModel.hpp"

static z3::model* checkModel(lua_State* L, int index) {
  return luaW_check<z3::model>(L, index);
}

// Evaluate an expression in this model
static int Model_eval(lua_State* L) {
  auto* model = checkModel(L, 1);
  auto* expr = luaW_check<z3::expr>(L, 2);
  bool model_completion = lua_toboolean(L, 3);
  try {
    auto* result = new z3::expr(model->eval(*expr, model_completion));
    luaW_push<z3::expr>(L, result);
    return 1;
  } catch (const z3::exception& e) {
    return luaL_error(L, "z3 error: %s", e.msg());
  }
}

// Get the number of constants in the model
static int Model_num_consts(lua_State* L) {
  auto* model = checkModel(L, 1);
  lua_pushinteger(L, model->num_consts());
  return 1;
}

// Get the number of functions in the model
static int Model_num_funcs(lua_State* L) {
  auto* model = checkModel(L, 1);
  lua_pushinteger(L, model->num_funcs());
  return 1;
}

// Get the number of sorts in the model
static int Model_num_sorts(lua_State* L) {
  auto* model = checkModel(L, 1);
  lua_pushinteger(L, model->num_sorts());
  return 1;
}

// Get a constant declaration by index
static int Model_get_const_decl(lua_State* L) {
  auto* model = checkModel(L, 1);
  unsigned index = static_cast<unsigned>(luaL_checkinteger(L, 2) - 1);  // Lua is 1-indexed
  if (index >= model->num_consts()) {
    return luaL_error(L, "index out of range");
  }
  z3::func_decl decl = model->get_const_decl(index);
  // Return the name and value as a table
  lua_newtable(L);
  lua_pushstring(L, decl.name().str().c_str());
  lua_setfield(L, -2, "name");
  auto* value = new z3::expr(model->get_const_interp(decl));
  luaW_push<z3::expr>(L, value);
  lua_setfield(L, -2, "value");
  return 1;
}

// Iterator for constants
static int Model_consts_iterator(lua_State* L) {
  auto* model = luaW_check<z3::model>(L, lua_upvalueindex(1));
  unsigned index = static_cast<unsigned>(lua_tointeger(L, lua_upvalueindex(2)));
  if (index >= model->num_consts()) {
    return 0;
  }
  z3::func_decl decl = model->get_const_decl(index);
  lua_pushstring(L, decl.name().str().c_str());
  auto* value = new z3::expr(model->get_const_interp(decl));
  luaW_push<z3::expr>(L, value);
  // Update index
  lua_pushinteger(L, index + 1);
  lua_replace(L, lua_upvalueindex(2));
  return 2;
}

static int Model_consts(lua_State* L) {
  luaW_check<z3::model>(L, 1);
  lua_pushvalue(L, 1);  // model
  lua_pushinteger(L, 0);  // index
  lua_pushcclosure(L, Model_consts_iterator, 2);
  return 1;
}

// Get the value of a constant as a Lua value (when possible)
static int Model_get_value(lua_State* L) {
  auto* model = checkModel(L, 1);
  auto* expr = luaW_check<z3::expr>(L, 2);
  try {
    z3::expr result = model->eval(*expr, true);
    if (result.is_bool()) {
      if (result.is_true()) {
        lua_pushboolean(L, 1);
      } else if (result.is_false()) {
        lua_pushboolean(L, 0);
      } else {
        lua_pushnil(L);
      }
    } else if (result.is_int() || result.is_numeral()) {
      int64_t val;
      if (result.is_numeral_i64(val)) {
        lua_pushinteger(L, static_cast<lua_Integer>(val));
      } else {
        lua_pushstring(L, result.to_string().c_str());
      }
    } else {
      lua_pushstring(L, result.to_string().c_str());
    }
    return 1;
  } catch (const z3::exception& e) {
    return luaL_error(L, "z3 error: %s", e.msg());
  }
}

static int Model_tostring(lua_State* L) {
  auto* model = checkModel(L, 1);
  lua_pushstring(L, model->to_string().c_str());
  return 1;
}

static void Model_deallocator(lua_State* L, z3::model* model) {
  delete model;
}

static luaL_Reg modelTable[] = {
    {NULL, NULL}
};

static luaL_Reg modelMetatable[] = {
    {"eval", Model_eval},
    {"get_value", Model_get_value},
    {"num_consts", Model_num_consts},
    {"num_funcs", Model_num_funcs},
    {"num_sorts", Model_num_sorts},
    {"get_const_decl", Model_get_const_decl},
    {"consts", Model_consts},
    {"__tostring", Model_tostring},
    {NULL, NULL}
};

int luaopen_z3_model(lua_State* L) {
  luaW_register<z3::model>(
      L,
      "z3.model",
      modelTable,
      modelMetatable,
      nullptr,
      Model_deallocator
  );
  return 1;
}
