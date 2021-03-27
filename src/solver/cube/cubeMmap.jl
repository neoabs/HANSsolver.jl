"""
Function creates writeable object and creates & writes -∞ Array to it. Array Dimmensions are not stored. 
# Arguments
- `dimsize::NTuple{N,:<Int}`: Dimmensions of an array to write
- `dir_name::String = "/tmp/io.mmap": Path to write a file.
"""
function create_mmap_array(dimsize::NTuple{N,<:Integer}, dir_name::String = "/tmp/io.mmap") where N
    
    s = Mmap.open(dir_name, "w+") 
    Mmap.write(s, repeat([-Inf::Float64], dimsize... ) )
    close(s)

end

"""
Function opens with r+ permission a readable file with an array and returns IO Array (Mmap)  
# Arguments
- `dimsize::NTuple{N,:<Int}`: Ntuple of dimensions of Array
- `dir_name::String = "/tmp/io.mmap": Path to a file.
"""
function read2write_mmap_array(dimsize::NTuple{N,<:Integer}, dir_path::String = "/tmp/io.mmap") where N
    
    s = Mmap.open(dir_path, "r+")
    A = Mmap.mmap(s, Array{Float64,length(dimsize)}, dimsize)
    close(s)
    return(A)
    
end

"""
Function opens with r permission a readable file with an array and returns IO Array (Mmap)  
# Arguments
- `dimsize::NTuple{N,:<Int}`: Ntuple of dimensions of Array
- `dir_name::String = "/tmp/io.mmap": Path to a file.
"""
function read_mmap_array(dimsize::NTuple{N,<:Integer}, dir_path::String = "/tmp/io.mmap") where N
    
    s = Mmap.open(dir_path, "r")
    A = Mmap.mmap(s, Array{Float64,length(dimsize)}, dimsize)
    close(s)
    return(A)
    
end

"""
Function that returns Utility for given prices and coordinates. Requires precompilation of Utility Cube. MMap (hard drive) version. Requires precompilation of utils cube on disk. Accesses values directly. Requires few GB of space.
# Arguments
- `ind_vec::NTuple{M,<:Integer}`: coordinates of Utility.
- `mdl::Model`: mutable struct Model."""

function cube_Mmap( ind_vec::Vector{<:Integer}, mdl::Model, additional_args=nothing)

    grid = mdl.GridDef
    index, status = ndim2lin(ind_vec, mdl.GridDef)
    return(mdl.Utils.qb[ status ][ index ])

end

"""
Function building cube. GPU version. Requires precompilation of utils cube in VRAM. Accesses values directly.Requires as many GPUs as there are statuses.
# Arguments
- `mdl::ModelInit`: struct ModelInit.
# Examples```julia-repl\njulia> execute_cube(my_model, "CPU")\n```
"""
function cube_Mmap_qb(mdl::Model)
    
    n_dim = tuple( length.(mdl.GridDef.Grids)[1:(end-1)]... )
    cube = Vector{Array{Float64}}()

    for status = mdl.GridDef.Grids[end]
        
        path_ = joinpath(pwd(), "/tmp/utils_" * string(status) * ".io")
        create_mmap_array(n_dim, path_)
        append!( cube, [ read2write_mmap_array( n_dim, path_ ) ] )
        
    end
    
    Threads.@threads for idx = CartesianIndices(n_dim)
        
        for status = mdl.GridDef.Grids[end]
            
            ind_vec = CartesianIndex( idx, status )
            cube[status][idx] =  mdl.HAutility( mdl.HAconstraint( Tuple(ind_vec) , mdl )... )
            
        end
        
    end

    cube_out = Vector{Array{Float64}}()
      
    for status = mdl.GridDef.Grids[end]
        
        Mmap.sync!(cube[status])
        path_ = "/tmp/utils_" * string(status) * ".io"
        
        append!( cube_out, [read_mmap_array(n_dim, path_)])
        
    end

    return(cube_out)
    
end

