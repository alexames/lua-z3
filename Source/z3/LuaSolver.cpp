#include "z3/LuaSolver.hpp"
#include <sstream>

static z3::solver* checkSolver(lua_State* L, int index) {
  return luaW_check<z3::solver>(L, index);
}

// Add an assertion to the solver
static int Solver_add(lua_State* L) {
  auto* solver = checkSolver(L, 1);
  auto* expr = luaW_check<z3::expr>(L, 2);
  solver->add(*expr);
  return 0;
}

// Check satisfiability
static int Solver_check(lua_State* L) {
  auto* solver = checkSolver(L, 1);
  z3::check_result result = solver->check();
  switch (result) {
    case z3::sat:
      lua_pushstring(L, "sat");
      break;
    case z3::unsat:
      lua_pushstring(L, "unsat");
      break;
    case z3::unknown:
      lua_pushstring(L, "unknown");
      break;
  }
  return 1;
}

// Get the model (only valid after check() returns sat)
static int Solver_get_model(lua_State* L) {
  auto* solver = checkSolver(L, 1);
  try {
    auto* model = new z3::model(solver->get_model());
    luaW_push<z3::model>(L, model);
    return 1;
  } catch (const z3::exception& e) {
    return luaL_error(L, "z3 error: %s", e.msg());
  }
}

// Reset the solver
static int Solver_reset(lua_State* L) {
  auto* solver = checkSolver(L, 1);
  solver->reset();
  return 0;
}

// Push a context (for incremental solving)
static int Solver_push(lua_State* L) {
  auto* solver = checkSolver(L, 1);
  solver->push();
  return 0;
}

// Pop a context
static int Solver_pop(lua_State* L) {
  auto* solver = checkSolver(L, 1);
  unsigned n = static_cast<unsigned>(luaL_optinteger(L, 2, 1));
  solver->pop(n);
  return 0;
}

// Get assertions
static int Solver_assertions(lua_State* L) {
  auto* solver = checkSolver(L, 1);
  z3::expr_vector assertions = solver->assertions();
  lua_newtable(L);
  for (unsigned i = 0; i < assertions.size(); ++i) {
    auto* expr = new z3::expr(assertions[i]);
    luaW_push<z3::expr>(L, expr);
    lua_rawseti(L, -2, i + 1);
  }
  return 1;
}

// Get reason unknown (when check returns unknown)
static int Solver_reason_unknown(lua_State* L) {
  auto* solver = checkSolver(L, 1);
  lua_pushstring(L, solver->reason_unknown().c_str());
  return 1;
}

// Get solver statistics
static int Solver_statistics(lua_State* L) {
  auto* solver = checkSolver(L, 1);
  z3::stats stats = solver->statistics();
  std::ostringstream oss;
  oss << stats;
  lua_pushstring(L, oss.str().c_str());
  return 1;
}

// Convert solver to SMT-LIB2 format
static int Solver_to_smt2(lua_State* L) {
  auto* solver = checkSolver(L, 1);
  lua_pushstring(L, solver->to_smt2().c_str());
  return 1;
}

static int Solver_tostring(lua_State* L) {
  auto* solver = checkSolver(L, 1);
  lua_pushstring(L, solver->to_smt2().c_str());
  return 1;
}

// Allocator - requires a context
static z3::solver* Solver_allocator(lua_State* L) {
  auto* ctx = luaW_check<z3::context>(L, 1);
  return new z3::solver(*ctx);
}

static void Solver_deallocator(lua_State* L, z3::solver* solver) {
  delete solver;
}

static luaL_Reg solverTable[] = {
    {NULL, NULL}
};

static luaL_Reg solverMetatable[] = {
    {"add", Solver_add},
    {"check", Solver_check},
    {"get_model", Solver_get_model},
    {"reset", Solver_reset},
    {"push", Solver_push},
    {"pop", Solver_pop},
    {"assertions", Solver_assertions},
    {"reason_unknown", Solver_reason_unknown},
    {"statistics", Solver_statistics},
    {"to_smt2", Solver_to_smt2},
    {"__tostring", Solver_tostring},
    {NULL, NULL}
};

int luaopen_z3_solver(lua_State* L) {
  luaW_register<z3::solver>(
      L,
      "z3.solver",
      solverTable,
      solverMetatable,
      Solver_allocator,
      Solver_deallocator
  );
  return 1;
}
