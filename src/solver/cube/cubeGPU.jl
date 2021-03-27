# """
# Function that returns Utility for given prices and coordinates. Requires precompilation of Utility Cube. GPU version. Requires precompilation of utils cube in VRAM. Accesses values directly. Requires as many GPUs as there are statuses.
# # Arguments
# - `ind_vec::NTuple{M,<:Integer}`: coordinates of Utility.
# - `mdl::Model`: mutable struct Model.
# """

# function cube_GPU( ind_vec::Vector{<:Integer}, mdl::Model, additional_args=nothing)

#     grid = mdl.GridDef
#     index, status = ndim2lin(ind_vec, grid)
#     set_device(status-1)
#     return(mdl.Utils.qb[ status ][ index ])

# end

# """
# Function building cube. GPU version. Requires precompilation of utils cube in VRAM. Accesses values directly.Requires as many GPUs as there are statuses.
# # Arguments
# - `mdl::Model`: struct Model.
# """
# function cube_GPU_qb(mdl::Model) where M
    
#     n_dim = tuple( length.(mdl.GridDef.Grids)[1:(end-1)]... )
#     cube = Vector{AFArray}()
    
#     for status = mdl.GridDef.Grids[end]
        
#         set_device(status-1)
#         append!( cube, [AFArray( repeat([-Inf::Float64], n_dim... ) )] )
        
#     end
    
#     for status = mdl.GridDef.Grids[end]
        
#         set_device( status - 1)
        
#         Threads.@threads for idx = CartesianIndices(n_dim)
            
#             ind_vec = CartesianIndex( idx, status )
            
#             cube[status][idx] =  mdl.HAutility( mdl.HAconstraint( Tuple(ind_vec) , mdl )... )
            
#         end
        
#     end
    
    
#     return(cube)
    
# end