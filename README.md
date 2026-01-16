# lua-z3

Lua 5.4 bindings for the [Z3 theorem prover](https://github.com/Z3Prover/z3).

## Installation

### Via vcpkg

Add to your `vcpkg.json`:

```json
{
  "dependencies": ["lua-z3"]
}
```

And to your `vcpkg-configuration.json`:

```json
{
  "registries": [
    {
      "kind": "git",
      "baseline": "<baseline>",
      "repository": "https://github.com/alexames/vcpkg-registry",
      "packages": ["lua-z3"]
    }
  ]
}
```

### Building from Source

```bash
git clone https://github.com/alexames/lua-z3.git
cd lua-z3
cmake -B Build
cmake --build Build --config Release
```

## Quick Start

```lua
local z3 = require("z3")

-- Create a context and solver
local ctx = z3.Context()
local solver = z3.Solver(ctx)

-- Create integer variables
local x = ctx:int_const("x")
local y = ctx:int_const("y")

-- Add constraints: x > 0, y > 0, x + y == 10
solver:add(x:gt(ctx:int_val(0)))
solver:add(y:gt(ctx:int_val(0)))
solver:add((x + y):eq(ctx:int_val(10)))

-- Check satisfiability
local result = solver:check()
if result == "sat" then
    local model = solver:get_model()
    print("Solution found:")
    print("  x =", model:get_value(x))
    print("  y =", model:get_value(y))
elseif result == "unsat" then
    print("No solution exists")
else
    print("Unknown: " .. solver:reason_unknown())
end
```

## API Reference

### z3.Context

The context manages all Z3 objects and global configuration.

```lua
local ctx = z3.Context()
```

#### Variable Creation

```lua
local b = ctx:bool_const("b")      -- Boolean variable
local x = ctx:int_const("x")       -- Integer variable
local r = ctx:real_const("r")      -- Real number variable
local bv = ctx:bv_const("bv", 32)  -- 32-bit bitvector
local s = ctx:string_const("s")    -- String variable
```

#### Literal Values

```lua
local t = ctx:bool_val(true)       -- Boolean literal
local n = ctx:int_val(42)          -- Integer literal
local r = ctx:real_val(3, 4)       -- Rational 3/4
local r2 = ctx:real_val("3.14")    -- Real from string
local bv = ctx:bv_val(255, 8)      -- 8-bit value 255
local s = ctx:string_val("hello")  -- String literal
```

#### Sort (Type) Creation

```lua
local bool_sort = ctx:bool_sort()
local int_sort = ctx:int_sort()
local real_sort = ctx:real_sort()
local bv32_sort = ctx:bv_sort(32)
local string_sort = ctx:string_sort()
```

### z3.Solver

The solver checks satisfiability of constraints.

```lua
local solver = z3.Solver(ctx)
```

#### Methods

```lua
solver:add(expr)           -- Add a constraint
solver:check()             -- Returns "sat", "unsat", or "unknown"
solver:get_model()         -- Get the model (after check() returns "sat")
solver:reset()             -- Clear all assertions
solver:push()              -- Create a backtracking point
solver:pop()               -- Backtrack
solver:pop(n)              -- Backtrack n levels
solver:assertions()        -- Get all assertions as a table
solver:to_smt2()           -- Convert to SMT-LIB2 format
solver:statistics()        -- Get solver statistics
solver:reason_unknown()    -- Get reason when check() returns "unknown"
```

### z3.expr

Expressions represent formulas and terms.

#### Arithmetic Operations (via metamethods)

```lua
local sum = x + y           -- Addition
local diff = x - y          -- Subtraction
local prod = x * y          -- Multiplication
local quot = x / y          -- Division
local rem = x % y           -- Modulo (use :mod() for z3 mod)
local neg = -x              -- Negation
local pow = x ^ y           -- Exponentiation
```

#### Comparison Operations (return z3 expressions)

```lua
x:eq(y)                     -- x == y
x:ne(y)                     -- x != y
x:lt(y)                     -- x < y
x:le(y)                     -- x <= y
x:gt(y)                     -- x > y
x:ge(y)                     -- x >= y
```

#### Logical Operations

```lua
a:land(b)                   -- a AND b
a:lor(b)                    -- a OR b
a:lnot()                    -- NOT a
a:implies(b)                -- a => b
a:ite(then_expr, else_expr) -- if a then then_expr else else_expr
```

#### Bitvector Operations

```lua
a:bvand(b)                  -- Bitwise AND
a:bvor(b)                   -- Bitwise OR
a:bvxor(b)                  -- Bitwise XOR
a:bvnot()                   -- Bitwise NOT
a:bvshl(b)                  -- Shift left
a:bvshr(b)                  -- Logical shift right
a:bvashr(b)                 -- Arithmetic shift right
a:extract(high, low)        -- Extract bits [high:low]
a:concat(b)                 -- Concatenate bitvectors
```

#### Other Methods

```lua
expr:get_sort()             -- Get the sort (type) of the expression
expr:simplify()             -- Simplify the expression
expr:substitute(from, to)   -- Substitute from with to
expr:is_bool()              -- Check if boolean
expr:is_int()               -- Check if integer
expr:is_real()              -- Check if real
expr:is_bv()                -- Check if bitvector
expr:is_const()             -- Check if constant
tostring(expr)              -- String representation
```

### z3.model

Models represent solutions to satisfiable constraints.

```lua
local model = solver:get_model()
```

#### Methods

```lua
model:eval(expr)            -- Evaluate expression in the model
model:eval(expr, true)      -- Evaluate with model completion
model:get_value(expr)       -- Get Lua value (bool/integer/string)
model:num_consts()          -- Number of constants
model:num_funcs()           -- Number of functions
model:num_sorts()           -- Number of sorts
model:get_const_decl(i)     -- Get i-th constant {name, value}
model:consts()              -- Iterator over constants
tostring(model)             -- String representation
```

### z3.sort

Sorts represent types.

```lua
sort:is_bool()
sort:is_int()
sort:is_real()
sort:is_arith()
sort:is_bv()
sort:is_array()
sort:is_datatype()
sort:bv_size()              -- Size for bitvector sorts
sort:name()                 -- Sort name
tostring(sort)              -- String representation
```

### Module Functions

```lua
z3.And(a, b, ...)           -- Conjunction of multiple expressions
z3.Or(a, b, ...)            -- Disjunction of multiple expressions
z3.Not(a)                   -- Negation
z3.Implies(a, b)            -- Implication
z3.Ite(cond, then, else)    -- If-then-else
z3.Distinct(a, b, ...)      -- All arguments are pairwise distinct
z3.Sum(a, b, ...)           -- Sum of expressions
z3.Product(a, b, ...)       -- Product of expressions
```

## Examples

### Sudoku Solver

```lua
local z3 = require("z3")

local ctx = z3.Context()
local solver = z3.Solver(ctx)

-- Create 9x9 grid of integer variables
local cells = {}
for i = 1, 9 do
    cells[i] = {}
    for j = 1, 9 do
        cells[i][j] = ctx:int_const(string.format("cell_%d_%d", i, j))
        -- Each cell is between 1 and 9
        solver:add(cells[i][j]:ge(ctx:int_val(1)))
        solver:add(cells[i][j]:le(ctx:int_val(9)))
    end
end

-- Row constraints: all different
for i = 1, 9 do
    local row = {}
    for j = 1, 9 do
        row[j] = cells[i][j]
    end
    solver:add(z3.Distinct(table.unpack(row)))
end

-- Column constraints
for j = 1, 9 do
    local col = {}
    for i = 1, 9 do
        col[i] = cells[i][j]
    end
    solver:add(z3.Distinct(table.unpack(col)))
end

-- 3x3 box constraints
for box_i = 0, 2 do
    for box_j = 0, 2 do
        local box = {}
        for i = 1, 3 do
            for j = 1, 3 do
                table.insert(box, cells[box_i * 3 + i][box_j * 3 + j])
            end
        end
        solver:add(z3.Distinct(table.unpack(box)))
    end
end

-- Add initial values (0 = empty)
local puzzle = {
    {5, 3, 0, 0, 7, 0, 0, 0, 0},
    {6, 0, 0, 1, 9, 5, 0, 0, 0},
    -- ... rest of puzzle
}

for i = 1, 9 do
    for j = 1, 9 do
        if puzzle[i][j] ~= 0 then
            solver:add(cells[i][j]:eq(ctx:int_val(puzzle[i][j])))
        end
    end
end

if solver:check() == "sat" then
    local model = solver:get_model()
    for i = 1, 9 do
        local row = {}
        for j = 1, 9 do
            row[j] = model:get_value(cells[i][j])
        end
        print(table.concat(row, " "))
    end
end
```

### Bitvector Arithmetic

```lua
local z3 = require("z3")

local ctx = z3.Context()
local solver = z3.Solver(ctx)

-- 32-bit bitvectors
local x = ctx:bv_const("x", 32)
local y = ctx:bv_const("y", 32)

-- Find x, y such that x ^ y == 0xDEADBEEF and x & y == 0
solver:add(x:bvxor(y):eq(ctx:bv_val(0xDEADBEEF, 32)))
solver:add(x:bvand(y):eq(ctx:bv_val(0, 32)))

if solver:check() == "sat" then
    local model = solver:get_model()
    print("x =", model:eval(x))
    print("y =", model:eval(y))
end
```

## License

MIT License
