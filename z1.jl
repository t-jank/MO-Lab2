using JuMP
using GLPK
model=Model(GLPK.Optimizer)

@variable(model,x1>=0, Int)
@variable(model,x2>=0, Int)
@variable(model,x3>=0, Int)
@variable(model,x4>=0, Int)
@variable(model,x5>=0, Int)
@variable(model,x6>=0, Int)
@variable(model,x7>=0, Int)
@variable(model,x8>=0, Int)
@variable(model,x9>=0, Int)
@variable(model,x10>=0, Int)
@variable(model,x11>=0, Int)

@objective(model, Min, 1x1+2x3+2x5+1x6+2x7+1x8+2x10+1x11+7*(3x1+2x2+2x3+1x4+1x5+1x6-110)+5*(1x2+3x4+2x5+1x6+4x7+3x8+2x9+1x10-120)+3*(1x2+2x3+1x5+3x6+2x8+4x9+5x10+7x11-80))

@constraint(model, c7, 3x1+2x2+2x3+1x4+1x5+1x6 >= 110)
@constraint(model, c5, 1x2+3x4+2x5+1x6+4x7+3x8+2x9+1x10 >= 120)
@constraint(model, c3, 1x2+2x3+1x5+3x6+2x8+4x9+5x10+7x11 >= 80)

print(model)

optimize!(model)
println()
println("funkcja celu = ", objective_value(model))
println("x1 = ",value(x1))
println("x2 = ",value(x2))
println("x3 = ",value(x3))
println("x4 = ",value(x4))
println("x5 = ",value(x5))
println("x6 = ",value(x6))
println("x7 = ",value(x7))
println("x8 = ",value(x8))
println("x9 = ",value(x9))
println("x10 = ",value(x10))
println("x11 = ",value(x11))

