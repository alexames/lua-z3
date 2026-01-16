# Claude Code Project Instructions

This file contains instructions for Claude Code when working on the lua-z3 project.

## Project Overview

lua-z3 is a Lua 5.4 binding for the Z3 theorem prover, written in C++23 using the LuaWrapper library for object bindings.

### Key Architecture Concepts

- **LuaWrapper Bindings**: Uses LuaWrapper to expose Z3 C++ objects to Lua with proper garbage collection
- **Shared Library**: Builds as a shared library (.dll/.so) that can be loaded directly by Lua's `require`
- **vcpkg Integration**: Dependencies managed via vcpkg with custom registry support

### Important Files and Directories

| Path | Purpose |
|------|---------|
| `Source/z3/` | Core binding implementation |
| `Source/z3/Include/z3/` | Public headers |
| `Source/z3/LuaZ3.cpp` | Main module entry point (`luaopen_z3`) |
| `Source/z3/LuaContext.cpp` | z3::context bindings |
| `Source/z3/LuaSolver.cpp` | z3::solver bindings |
| `Source/z3/LuaExpr.cpp` | z3::expr bindings (expressions and formulas) |
| `Source/z3/LuaSort.cpp` | z3::sort bindings (types) |
| `Source/z3/LuaModel.cpp` | z3::model bindings (solutions) |
| `cmake/` | CMake helper modules |

### CMake Build System

The build uses helper functions from the `Targets` vcpkg package:

```cmake
cpp_library(TARGET z3 TYPE SHARED SOURCES "*.cpp" DEPENDENCIES ...)
```

---

## Git Workflow (IMPORTANT)

### Never Commit Directly to Main

**All changes must go through a feature or bugfix branch.** Do not commit directly to `main`.

### Branch Naming

| Change Type | Branch Prefix | Example |
|-------------|---------------|---------|
| New feature | `feature/` | `feature/array-bindings` |
| Bug fix | `bug/` | `bug/memory-leak-fix` |
| Refactoring | `refactor/` | `refactor/api-cleanup` |
| Documentation | `docs/` | `docs/api-reference` |
| Tests | `test/` | `test/solver-coverage` |

### Workflow Steps

```bash
# 1. Start from main and create a branch
git checkout main
git pull origin main
git checkout -b feature/descriptive-name

# 2. Make small, focused commits
git add <files>
git commit -m "Short description of change"

# 3. When complete, push and create PR
git push -u origin feature/descriptive-name
gh pr create --title "Feature: Description" --body "..."
```

### Commit Guidelines

**Small, focused commits.** Each commit should:
- Represent a single logical change
- Be independently reviewable
- Compile successfully
- Have a descriptive message

**Commit message format:**
```
<short summary>

<optional detailed description>
```

**Do NOT use conventional commit prefixes** like `feat:`, `fix:`, `docs:`, etc.
Just write a clear, descriptive summary starting with a capital letter.

---

## Testing Requirements

Tests should accompany changes whenever possible:

- **New bindings:** Add tests for new Z3 functionality
- **Bug fixes:** Add a test that reproduces the bug
- **API changes:** Update existing tests

### Running Tests

```bash
cd Build
ctest --output-on-failure
```

---

## Build Commands

```bash
# Configure
cmake -B Build

# Build
cmake --build Build --config Release

# Run tests
cd Build && ctest --output-on-failure
```

---

## Code Patterns and Conventions

### Adding New Bindings

Follow the existing pattern for new Z3 types:

1. Create header `Source/z3/Include/z3/LuaNewType.hpp`
2. Create implementation `Source/z3/LuaNewType.cpp`
3. Add `luaopen_z3_newtype()` function
4. Register in `LuaZ3.cpp`
5. Add to `CMakeLists.txt` SOURCES

### LuaWrapper Usage Pattern

```cpp
// Check and extract C++ object from Lua stack
static z3::mytype* checkMyType(lua_State* L, int index) {
  return luaW_check<z3::mytype>(L, index);
}

// Method implementation
static int MyType_method(lua_State* L) {
  auto* obj = checkMyType(L, 1);
  // ... use obj ...
  return 0;
}

// Method table
static luaL_Reg myTypeMetatable[] = {
    {"method", MyType_method},
    {"__tostring", MyType_tostring},
    {NULL, NULL}
};

// Registration function
int luaopen_z3_mytype(lua_State* L) {
  luaW_register<z3::mytype>(
      L, "z3.mytype",
      myTypeTable, myTypeMetatable,
      MyType_allocator, MyType_deallocator
  );
  return 1;
}
```

### Memory Management

- Objects created with `new` in allocators are deleted by deallocators
- Objects returned to Lua (via `luaW_push`) are owned by Lua and GC'd automatically
- Always use `new` when pushing z3 objects to Lua stack

### Error Handling

Wrap z3 operations that might throw in try-catch:

```cpp
try {
  // z3 operation
} catch (const z3::exception& e) {
  return luaL_error(L, "z3 error: %s", e.msg());
}
```

---

## Pre-Submission Checklist

Before pushing a branch:

- [ ] Code compiles without warnings
- [ ] Tests pass
- [ ] Commits are small and focused
- [ ] Commit messages are descriptive
- [ ] Branch is named appropriately (`feature/`, `bug/`, etc.)
- [ ] PR description is complete

---

## vcpkg Registry

This library is published to `https://github.com/alexames/vcpkg-registry`. To update the port:

```bash
python vcpkger.py update lua-z3 \
  --github-repo 'alexames/lua-z3' \
  --commit-hash <commit> \
  --version '<version>' \
  --port-version 0 \
  --github-token <token>
```

---

## Lua API Overview

### Basic Usage

```lua
local z3 = require("z3")

-- Create a context and solver
local ctx = z3.Context()
local solver = z3.Solver(ctx)

-- Create integer variables
local x = ctx:int_const("x")
local y = ctx:int_const("y")

-- Add constraints
solver:add(x:gt(y))       -- x > y
solver:add(y:gt(ctx:int_val(0)))  -- y > 0
solver:add(x:lt(ctx:int_val(10))) -- x < 10

-- Check satisfiability
if solver:check() == "sat" then
  local model = solver:get_model()
  print("x =", model:get_value(x))
  print("y =", model:get_value(y))
end
```

### Expression Operations

- Arithmetic: `+`, `-`, `*`, `/`, `%`, `^` (via metamethods)
- Comparison: `:eq()`, `:ne()`, `:lt()`, `:le()`, `:gt()`, `:ge()`
- Logical: `:land()`, `:lor()`, `:lnot()`, `:implies()`
- Bitvector: `:bvand()`, `:bvor()`, `:bvxor()`, `:bvnot()`, `:extract()`, `:concat()`

### Module Functions

- `z3.And(...)` - Logical AND of multiple expressions
- `z3.Or(...)` - Logical OR of multiple expressions
- `z3.Not(expr)` - Logical negation
- `z3.Implies(a, b)` - Implication
- `z3.Ite(cond, then, else)` - If-then-else
- `z3.Distinct(...)` - All arguments are distinct
