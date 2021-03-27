
using HANSsolver, NLsolve, Optim
include("subfiles/load_parameters.jl")

include("subfiles/load_AddPrices.jl")
include("subfiles/load_AltReturn.jl")
include("subfiles/load_GridDef.jl")
include("subfiles/load_HAconstraintAlt.jl")
include("subfiles/load_HAconstraint.jl")
include("subfiles/load_MC.jl")

include("subfiles/load_Utility.jl")
include("subfiles/load_VFafterprocess.jl")

prices = Vector{Float64}( [ 0.8177568860700106, 0.8130278740954832 ] )
mdl_init = ModelInit(  prices
, additional_prices
, grid_def
, λ
, β
, utility
, budget_constraint
, alt_constraint
, nonnaivebanks
, alt_return
, clear_marketing
, initialize_paremeters
);

mdl = modeltest(mdl_init);
# hans_solver(mdl_init)

print("DONE")