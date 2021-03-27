
"""
Function to create GridDef object. Accepts vector of names (AbstractString) and vector of grtid points (Vectors of Real and Abstract Ranges are accepted) and throws out GridDef

Take Note: last variable is not doubled
# Examples
```julia-repl
julia> make_dimmensions(["a", "b", "c"], [[1.0, 1.1, 1.2], (0:10)/10, [1 2]])
GridDef(["a₁", "b₁", "a₂", "b₂", "c"], AbstractArray{Float64,1}[[1.0, 1.1, 1.2], 0.0:0.1:1.0, [1.0, 1.1, 1.2], 0.0:0.1:1.0],[1 2])
```
"""
function make_dimmensions(var_names::Vector{<:AbstractString}, var_grid::Vector{} ) #where T #<: Union{AbstractVector{<:Real},AbstractRange}
    
    VarNames = Vector{String}()
    Grids = Vector() 
    
    for i=1:(length(var_names)-1)
    
        NewVar1 =  var_names[i] * "₁"
        # NewVar2 =  var_names[i] * "₂"
    
        push!(VarNames, NewVar1)
        push!(Grids, var_grid[i])
    
    end

    for i=1:(length(var_names)-1)
    
        # NewVar1 =  var_names[i] * "₁"
        NewVar2 =  var_names[i] * "₂"
    
        push!(VarNames, NewVar2)
        push!(Grids, var_grid[i])
    
    end
    
    push!(VarNames, var_names[length(var_names)])
    push!(Grids, Vector{Int64}(Int64.( var_grid[length(var_names)]) ) )
    
    VarNames = Tuple(Symbol.(VarNames))
    Grid = GridDef(VarNames,Grids)
    return(Grid)
    
end

"""
Function returns variable values for given coordinates. The last coordinate always refers to status (Example: employedunemployed)
# Arguments
- `ind_vec::Ntuple{M,<:Integer}`: Ntuple containing coordinates
- `grid::GridDef`: GridDef struct.
# Examples
```julia-repl
julia> get_vars((1,1,1,1),my_grid)
```
"""
function get_vars(ind_vec::NTuple{N,<:Integer}, grid::GridDef) where N
        
    val = ( grid.Grids[i][ind_vec[i]] for i = 1:length(grid.Grids) )
    
    return( NamedTuple{grid.VarNames}(val) )
    
end

"""
Function takes in a Vector (or BitArray{1}) and returns a 2-element tuple of Vectors. The first one denotes positions (indices) of the first occurences (consuecutive occurence of same symbols/values) of sequences,
 and the second of length(≥1) of these sequences
# Arguments
- `ind_vec::Ntuple{M,<:Integer}`: Ntuple containing coordinates
- `grid::GridDef`: GridDef struct.
# Examples
```julia-repl
julia> get_vars((1,1,1,1),my_grid)
```
"""
function sequence(x::Union{Vector,BitArray{1}})
    
    x = append!([1],cumsum(x[1:end-1] .!= x[2:end]).+1)
    tuple(
    [findfirst(y -> y == z, x) for z ∈ unique(x) ],
    [findlast(y -> y == z, x) for z ∈ unique(x) ] .- [findfirst(y -> y == z, x) for z ∈ unique(x) ] .+ 1
    )
    
end

