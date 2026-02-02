-- lua-z3 unit tests
-- Usage: lua tests/test_z3.lua

local unit = require 'llx.unit'
local z3 = require 'z3'

_ENV = unit.create_test_env(_ENV)

describe('z3.Context', function()
  it('should create a context', function()
    local ctx = z3.Context()
    expect(ctx).to_not.be_nil()
  end)

  it('should create boolean constants', function()
    local ctx = z3.Context()
    local b = ctx:bool_const("b")
    expect(b).to_not.be_nil()
    expect(tostring(b)).to.be_equal_to("b")
  end)

  it('should create integer constants', function()
    local ctx = z3.Context()
    local x = ctx:int_const("x")
    expect(x).to_not.be_nil()
    expect(tostring(x)).to.be_equal_to("x")
  end)

  it('should create real constants', function()
    local ctx = z3.Context()
    local r = ctx:real_const("r")
    expect(r).to_not.be_nil()
    expect(tostring(r)).to.be_equal_to("r")
  end)

  it('should create bitvector constants', function()
    local ctx = z3.Context()
    local bv = ctx:bv_const("bv", 32)
    expect(bv).to_not.be_nil()
    expect(tostring(bv)).to.be_equal_to("bv")
  end)

  it('should create literal values', function()
    local ctx = z3.Context()
    local t = ctx:bool_val(true)
    local f = ctx:bool_val(false)
    local n = ctx:int_val(42)

    expect(tostring(t)).to.be_equal_to("true")
    expect(tostring(f)).to.be_equal_to("false")
    expect(tostring(n)).to.be_equal_to("42")
  end)

  it('should create sorts', function()
    local ctx = z3.Context()
    local bool_sort = ctx:bool_sort()
    local int_sort = ctx:int_sort()
    local real_sort = ctx:real_sort()
    local bv_sort = ctx:bv_sort(16)

    expect(bool_sort:is_bool()).to.be_truthy()
    expect(int_sort:is_int()).to.be_truthy()
    expect(real_sort:is_real()).to.be_truthy()
    expect(bv_sort:is_bv()).to.be_truthy()
    expect(bv_sort:bv_size()).to.be_equal_to(16)
  end)
end)

describe('z3.Solver', function()
  it('should create a solver', function()
    local ctx = z3.Context()
    local solver = z3.Solver(ctx)
    expect(solver).to_not.be_nil()
  end)

  it('should solve a simple satisfiable problem', function()
    local ctx = z3.Context()
    local solver = z3.Solver(ctx)

    local x = ctx:int_const("x")
    solver:add(x:gt(ctx:int_val(0)))
    solver:add(x:lt(ctx:int_val(10)))

    local result = solver:check()
    expect(result).to.be_equal_to("sat")
  end)

  it('should detect unsatisfiable problems', function()
    local ctx = z3.Context()
    local solver = z3.Solver(ctx)

    local x = ctx:int_const("x")
    solver:add(x:gt(ctx:int_val(10)))
    solver:add(x:lt(ctx:int_val(5)))

    local result = solver:check()
    expect(result).to.be_equal_to("unsat")
  end)

  it('should get model after sat', function()
    local ctx = z3.Context()
    local solver = z3.Solver(ctx)

    local x = ctx:int_const("x")
    solver:add(x:eq(ctx:int_val(42)))

    expect(solver:check()).to.be_equal_to("sat")

    local model = solver:get_model()
    expect(model).to_not.be_nil()

    local value = model:get_value(x)
    expect(value).to.be_equal_to(42)
  end)

  it('should support push and pop', function()
    local ctx = z3.Context()
    local solver = z3.Solver(ctx)

    local x = ctx:int_const("x")
    solver:add(x:gt(ctx:int_val(0)))

    solver:push()
    solver:add(x:lt(ctx:int_val(0)))  -- Contradicts
    expect(solver:check()).to.be_equal_to("unsat")

    solver:pop()
    expect(solver:check()).to.be_equal_to("sat")
  end)

  it('should reset', function()
    local ctx = z3.Context()
    local solver = z3.Solver(ctx)

    local x = ctx:int_const("x")
    solver:add(x:gt(ctx:int_val(0)))
    solver:add(x:lt(ctx:int_val(0)))

    expect(solver:check()).to.be_equal_to("unsat")

    solver:reset()
    expect(solver:check()).to.be_equal_to("sat")
  end)

  it('should output SMT-LIB2 format', function()
    local ctx = z3.Context()
    local solver = z3.Solver(ctx)

    local x = ctx:int_const("x")
    solver:add(x:gt(ctx:int_val(0)))

    local smt2 = solver:to_smt2()
    expect(smt2).to.contain("declare-fun")
    expect(smt2).to.contain("assert")
  end)
end)

describe('z3.expr arithmetic', function()
  it('should support addition', function()
    local ctx = z3.Context()
    local x = ctx:int_const("x")
    local y = ctx:int_const("y")

    local sum = x + y
    expect(tostring(sum)).to.contain("+")
  end)

  it('should support subtraction', function()
    local ctx = z3.Context()
    local x = ctx:int_const("x")
    local y = ctx:int_const("y")

    local diff = x - y
    expect(tostring(diff)).to.contain("-")
  end)

  it('should support multiplication', function()
    local ctx = z3.Context()
    local x = ctx:int_const("x")
    local y = ctx:int_const("y")

    local prod = x * y
    expect(tostring(prod)).to.contain("*")
  end)

  it('should support negation', function()
    local ctx = z3.Context()
    local x = ctx:int_const("x")

    local neg = -x
    expect(tostring(neg)).to.contain("-")
  end)
end)

describe('z3.expr comparisons', function()
  it('should create equality expressions', function()
    local ctx = z3.Context()
    local solver = z3.Solver(ctx)
    local x = ctx:int_const("x")

    solver:add(x:eq(ctx:int_val(5)))
    expect(solver:check()).to.be_equal_to("sat")

    local model = solver:get_model()
    expect(model:get_value(x)).to.be_equal_to(5)
  end)

  it('should create inequality expressions', function()
    local ctx = z3.Context()
    local solver = z3.Solver(ctx)
    local x = ctx:int_const("x")

    solver:add(x:ne(ctx:int_val(0)))
    solver:add(x:ge(ctx:int_val(0)))
    solver:add(x:le(ctx:int_val(1)))

    expect(solver:check()).to.be_equal_to("sat")
    local model = solver:get_model()
    expect(model:get_value(x)).to.be_equal_to(1)
  end)
end)

describe('z3.expr logical operations', function()
  it('should support logical AND', function()
    local ctx = z3.Context()
    local solver = z3.Solver(ctx)

    local a = ctx:bool_const("a")
    local b = ctx:bool_const("b")

    solver:add(a:land(b))
    expect(solver:check()).to.be_equal_to("sat")

    local model = solver:get_model()
    expect(model:get_value(a)).to.be_truthy()
    expect(model:get_value(b)).to.be_truthy()
  end)

  it('should support logical OR', function()
    local ctx = z3.Context()
    local solver = z3.Solver(ctx)

    local a = ctx:bool_const("a")
    solver:add(a:lnot())  -- NOT a
    solver:add(a:lor(ctx:bool_val(true)))  -- a OR true

    expect(solver:check()).to.be_equal_to("sat")
  end)

  it('should support implication', function()
    local ctx = z3.Context()
    local solver = z3.Solver(ctx)

    local a = ctx:bool_const("a")
    local b = ctx:bool_const("b")

    -- a implies b, and a is true
    solver:add(a:implies(b))
    solver:add(a)

    expect(solver:check()).to.be_equal_to("sat")
    local model = solver:get_model()
    expect(model:get_value(b)).to.be_truthy()
  end)
end)

describe('z3 module functions', function()
  it('should support z3.And', function()
    local ctx = z3.Context()
    local solver = z3.Solver(ctx)

    local a = ctx:bool_const("a")
    local b = ctx:bool_const("b")
    local c = ctx:bool_const("c")

    solver:add(z3.And(a, b, c))
    expect(solver:check()).to.be_equal_to("sat")
  end)

  it('should support z3.Or', function()
    local ctx = z3.Context()
    local solver = z3.Solver(ctx)

    local a = ctx:bool_const("a")
    local b = ctx:bool_const("b")

    solver:add(a:lnot())
    solver:add(b:lnot())
    solver:add(z3.Or(a, b))  -- a OR b must be true, but both are false

    expect(solver:check()).to.be_equal_to("unsat")
  end)

  it('should support z3.Not', function()
    local ctx = z3.Context()
    local solver = z3.Solver(ctx)

    local a = ctx:bool_const("a")
    solver:add(z3.Not(a))

    expect(solver:check()).to.be_equal_to("sat")
    local model = solver:get_model()
    expect(model:get_value(a)).to.be_falsy()
  end)

  it('should support z3.Distinct', function()
    local ctx = z3.Context()
    local solver = z3.Solver(ctx)

    local x = ctx:int_const("x")
    local y = ctx:int_const("y")
    local z_var = ctx:int_const("z")

    -- All must be distinct and between 1-3
    solver:add(z3.Distinct(x, y, z_var))
    solver:add(x:ge(ctx:int_val(1)))
    solver:add(x:le(ctx:int_val(3)))
    solver:add(y:ge(ctx:int_val(1)))
    solver:add(y:le(ctx:int_val(3)))
    solver:add(z_var:ge(ctx:int_val(1)))
    solver:add(z_var:le(ctx:int_val(3)))

    expect(solver:check()).to.be_equal_to("sat")

    local model = solver:get_model()
    local vx = model:get_value(x)
    local vy = model:get_value(y)
    local vz = model:get_value(z_var)

    expect(vx).to_not.be_equal_to(vy)
    expect(vy).to_not.be_equal_to(vz)
    expect(vx).to_not.be_equal_to(vz)
  end)
end)

describe('z3.model', function()
  it('should iterate over constants', function()
    local ctx = z3.Context()
    local solver = z3.Solver(ctx)

    local x = ctx:int_const("x")
    local y = ctx:int_const("y")

    solver:add(x:eq(ctx:int_val(1)))
    solver:add(y:eq(ctx:int_val(2)))

    expect(solver:check()).to.be_equal_to("sat")
    local model = solver:get_model()

    local count = 0
    for name, value in model:consts() do
      count = count + 1
      expect(name).to_not.be_nil()
      expect(value).to_not.be_nil()
    end

    expect(count).to.be_equal_to(2)
  end)

  it('should evaluate expressions', function()
    local ctx = z3.Context()
    local solver = z3.Solver(ctx)

    local x = ctx:int_const("x")
    local y = ctx:int_const("y")

    solver:add(x:eq(ctx:int_val(3)))
    solver:add(y:eq(ctx:int_val(4)))

    expect(solver:check()).to.be_equal_to("sat")
    local model = solver:get_model()

    local sum_expr = x + y
    local result = model:eval(sum_expr)
    expect(tostring(result)).to.be_equal_to("7")
  end)
end)

describe('z3.sort', function()
  it('should query sort properties', function()
    local ctx = z3.Context()
    local x = ctx:int_const("x")
    local sort = x:get_sort()

    expect(sort:is_int()).to.be_truthy()
    expect(sort:is_bool()).to.be_falsy()
    expect(sort:is_arith()).to.be_truthy()
  end)

  it('should get sort name', function()
    local ctx = z3.Context()
    local int_sort = ctx:int_sort()

    expect(int_sort:name()).to.be_equal_to("Int")
  end)
end)

describe('z3 bitvector operations', function()
  it('should support bitvector AND', function()
    local ctx = z3.Context()
    local solver = z3.Solver(ctx)

    local x = ctx:bv_const("x", 8)
    local y = ctx:bv_const("y", 8)

    solver:add(x:eq(ctx:bv_val(0xFF, 8)))
    solver:add(y:eq(ctx:bv_val(0x0F, 8)))

    expect(solver:check()).to.be_equal_to("sat")
    local model = solver:get_model()

    local result = model:eval(x:bvand(y))
    expect(tostring(result)).to.be_equal_to("#x0f")
  end)

  it('should support bitvector OR', function()
    local ctx = z3.Context()
    local solver = z3.Solver(ctx)

    local x = ctx:bv_const("x", 8)
    local y = ctx:bv_const("y", 8)

    solver:add(x:eq(ctx:bv_val(0xF0, 8)))
    solver:add(y:eq(ctx:bv_val(0x0F, 8)))

    expect(solver:check()).to.be_equal_to("sat")
    local model = solver:get_model()

    local result = model:eval(x:bvor(y))
    expect(tostring(result)).to.be_equal_to("#xff")
  end)

  it('should support bitvector extract', function()
    local ctx = z3.Context()
    local solver = z3.Solver(ctx)

    local x = ctx:bv_const("x", 16)
    solver:add(x:eq(ctx:bv_val(0xABCD, 16)))

    expect(solver:check()).to.be_equal_to("sat")
    local model = solver:get_model()

    -- Extract high byte (bits 15:8)
    local high = model:eval(x:extract(15, 8))
    expect(tostring(high)).to.be_equal_to("#xab")

    -- Extract low byte (bits 7:0)
    local low = model:eval(x:extract(7, 0))
    expect(tostring(low)).to.be_equal_to("#xcd")
  end)
end)

describe('z3 expression simplification', function()
  it('should simplify expressions', function()
    local ctx = z3.Context()

    local x = ctx:int_const("x")
    local expr = x + ctx:int_val(0)  -- x + 0 should simplify to x
    local simplified = expr:simplify()

    expect(tostring(simplified)).to.be_equal_to("x")
  end)
end)

-- Run all tests
unit.run_unit_tests()
