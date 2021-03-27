"""
Function that returns Utility for given prices and coordinates.
Functional version. Computes values each time it's called. Requires little RAM and lots of time.
# Arguments
- `mdl::Model`: mutable struct Model.
- `method::String="Function"`: the method for the utils cube. Try "CPU", "GPU","Mmap","Function".
"""

function cube_function(ind_vec::Vector{<:Integer},mdl::Model,additional_args=nothing)

    mdl.HAutility( mdl.HAconstraint( Tuple(ind_vec) , mdl )... )

end