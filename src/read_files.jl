
"""
Function creates an Vector{String} of all files matching pattern. Mirrors list.files() from R. Prints whole path
"""
function lf(;path::String=pwd(), pattern::Regex=nothing, sub::Bool=true)
    
    files = Vector{String}()
    
    if sub
        
        for cpath = walkdir(path)
            
            x = joinpath.(cpath[1], cpath[3])


            if !isempty(x)
                idx = occursin.(pattern, cpath[3])
                append!(files, x[idx] )
            end
            
        end
        
    else
        
        files = filter(x->occursin(pattern,x), first(walkdir(path))[3])
        
    end
    
    return(files)
    
end
