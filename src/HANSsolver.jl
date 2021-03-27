module HANSsolver

    import Distributed, Mmap, Optim

    include("HANS_init.jl")
    include("HANS_utilities_functions.jl")
    include("solver/cube/cube.jl")
    include("solver/cube/cubeCPU.jl")
    include("solver/cube/cubeFunction.jl")
    # include("solver/cube/cubeGPU.jl")
    include("solver/cube/cubeMmap.jl")
    include("solver/density/prob_trans_iterator.jl")
    include("solver/dr_iterator/dr_CPU.jl")
    include("solver/dr_iterator/dr_iterator.base.jl")
    include("solver/solver.base.jl")
    include("solver/solver.functions.jl")
    include("tests/cubetest.jl")
    include("tests/modeltest.jl")

    export cubetest, modeltest, hans_solver, hans_solver_dynamic_griding, make_dimmensions, get_vars
    export Model, ModelInit, Utils, GridDef

end # module
