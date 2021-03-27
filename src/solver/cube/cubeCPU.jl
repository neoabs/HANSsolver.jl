"""
Function that returns Utility for given prices and coordinates. Requires precompilation of Utility Cube. 
CPU version. Requires precompilation of utils cube in RAM. Accesses values directly.
# Arguments
- `ind_vec::NTuple{M,<:Integer}`: coordinates of Utility.
- `mdl::Model`: mutable struct Model.
"""

function cube_CPU( ind_vec::Vector{Int64}, mdl::Model, additional_args=nothing)

    grid = mdl.GridDef
    status, index = (ind_vec[length(ind_vec)], CartesianIndex(Base.front(Tuple(ind_vec))))
    return(mdl.Utils.qb[ status ][ index ])

    
end
# function cube_CPU( ind_vec::CartesianIndex, mdl::Model, additional_args=nothing)

#     grid = mdl.GridDef
#     status, index = (ind_vec[length(ind_vec)], CartesianIndex(Base.front(Tuple(ind_vec))))
#     return(mdl.Utils.qb[ status ][ index ])

# end
function cube_CPU( ind_vec::CartesianIndex, status::Int, mdl::Model, additional_args=nothing)

    return(mdl.Utils.qb[ status ][ ind_vec ])

end

"""
Function building cube. CPU version. Requires precompilation of utils cube in RAM. Accesses values directly.
# Arguments
- `mdl::ModelInit`: struct ModelInit.
"""

function cube_CPU_qb(mdl::Model)
    
    n_dim = tuple(length.(mdl.GridDef.Grids)[1:(end-1)]...)
    cube = Vector( [repeat([-Inf::Float64], n_dim... ), repeat([-Inf::Float64], n_dim... )] )
    
    for status = mdl.GridDef.Grids[end]
        
        Threads.@threads for idx = CartesianIndices(n_dim)
            
            ind_vec = CartesianIndex( idx, status )
            cube[status][idx] =  mdl.HAutility( mdl.HAconstraint( Tuple(ind_vec) , mdl )... )
            
        end
        
    end
    
    return(cube)
    
end