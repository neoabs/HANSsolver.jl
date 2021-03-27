
"""
Function transforms ModelInit or Model into Model with empty properties
"""
function init_model(mdl::ModelInit)
    
    VF = zeros(Float64, *(length.(mdl.GridDef.Grids[1:Int64(floor(length(mdl.GridDef.Grids)/2))])...), length(mdl.GridDef.Grids[end]) )
    DR = Int64.(VF)
    # TM = Array{Int64,1}()
    PM = VF
    hstry = Vector{NTuple{length(mdl.Prices)*2, Float64}}()
    
    mdl_new = Model(  mdl.Prices
    , mdl.GetAP(mdl)
    , mdl.GetAP
    , mdl.GridDef
    , mdl.λ
    , mdl.β
    # , mdl.statvar
    , mdl.HAutility
    , Utils()
    , mdl.HAconstraint
    , mdl.HAconstraint_Alt
    # , mdl.VFstart
    , VF
    , DR
    , zeros(Float64,length(mdl.GridDef.Grids[end]))
    , mdl.VF_afterprocess
    , VF
    # , mdl.Ψᵢₙᵢₜ
    , Vector{Float64}()
    , mdl.alternate_return
    , mdl.MCcondition
    , hstry
    , mdl.InitParams
    )
    
    return(mdl_new)
    
end
function init_model(mdl::Model)
    
    #TODO: make arrays with already properly defined dimmensions. TOdo after solver is moreless done.
    # utils = Array{Float64}()
    VF = zeros(Float64, *(length.(mdl.GridDef.Grids[1:Int64(floor(length(mdl.GridDef.Grids)/2))])...), length(mdl.GridDef.Grids[end]) )
    DR = Int64.(VF)
    # TM = Array{Int64,1}()
    PM = VF
    hstry = Vector{NTuple{length(mdl.Prices)*2, Float64}}()
    
    mdl_new = Model(  mdl.Prices
    , mdl.GetAP(mdl)
    , mdl.GetAP
    , mdl.GridDef
    , mdl.λ
    , mdl.β
    # , mdl.statvar
    , mdl.HAutility
    , Utils()
    , mdl.HAconstraint
    , mdl.HAconstraint_Alt
    # , mdl.VFstart
    , VF
    , DR
    , zeros(Float64,length(mdl.GridDef.Grids[end]))
    , mdl.VF_afterprocess
    , VF
    # , mdl.Ψᵢₙᵢₜ
    , Vector{Float64}()
    , mdl.alternate_return
    , mdl.MCcondition
    , hstry
    , mdl.InitParams
    )
    
    return(mdl_new)
    
end

"""
Function calculates convergeance objective
# Arguments
- `prices::Vector{Float64}`: Vector containing prices
- `mdl::Model`: Model struct.
- `method_cube::String`: Method to use while calculating Utils.
"""
function objective_function(prices::Vector{Float64}, mdl::Model, method_cube::String)
    
    #Initialize and start iteration
    printstyled( "(I) ",bold = true, color = 159)
    printstyled( string("?? Old: ", prices), color = 226 )
    mdl, new_prices = iterate_mdl( prices, mdl, method_cube )
    
    #Update message within REPL
    stl = length( string("?? Old: ", prices) )
    printstyled( string("\e[", stl,"C", " New: ", new_prices), color = 208)
    message = string(" Objective Function Value: ",sum(abs.(100 * (prices - new_prices))))
    message *="\n"

    #TODO: change message updates by adding save cursosr location/load cursosr location.
    #Will make future updates much more easier

    printstyled(message,color = 63, bold = true )
    return( (1 + Ψ_punish_degree * Ψ_punish + DR_punish_degree * DR_punish) * sum(abs.(100 * (prices - new_prices))))
    
end

"""
Single iteration of Equilibrium, for given prices.
# Arguments
- `prices::Vector{Float64}`: Vector containing prices
- `mdl::Model`: Model struct.
- `method_cube::String`: Method to use while calculating Utils.
"""
function iterate_mdl(prices::Vector{Float64}, mdl::Model, method_cube::String)
    
    mdl.Prices = prices
    global DR_punish = false
    global Ψ_punish = false

    # Initialize
    mdl = init_model(mdl)
    printstyled( "\e[1G(C) ", bold = true, color = 20)

    # Get Utils
    mdl.Utils = execute_cube(mdl, method_cube)
    printstyled( "\e[1G(D) ", bold = true, color = 9)

    # Get decission rules
    iterate_decission_rules(mdl)
    printstyled( "\e[1G(Ψ) ", bold = true, color = 196)

    # Get distribution Ψ
    Ψ_search(mdl)

    # Update prices
    new_prices = copy(mdl.MCcondition(mdl))
    printstyled( "\e[1G(U) ", bold = true, color = 46)
    push!( mdl.History, tuple(mdl.Prices..., new_prices...) )

    return(mdl, new_prices )
    
end



"""
Function modifies Grid Definition based on `grid_power` variable. Grid power is understood as desired maximum number of positions on the grid. Two state variables with grid density 32 each have power 32`*`32=1024.
Decision rules (mdl.DR) are analysed and grid values that are never used are recylced and allocated to space where two or more neighbouring grid points are utilized. Spaces with more neighbouring points are prioritized when assigning points. Number of points is based on `grid_power`.

Returns __`GridDef`__ object

Requires total remake

# Arguments
- `mdl::Model`: Model with DR
- `grid_power::Int`: GridDef struct.
# Examples
```julia-repl
julia> update_grid(my_mdl,2048)
```
"""
function update_grid(mdl::Model,grid_power::Int=*(length.(mdl.GridDef.Grids[1:(end÷2)])...) )
    
    dr_temp = vec([1])
    
    while true
        
        check = length(dr_temp)
        dr_temp = append!(dr_temp, vec(mdl.DR[dr_temp,:]) )
        dr_temp = unique(dr_temp[dr_temp .!= 0])
        
        (check == length(dr_temp)) && (break)
        
    end 
    
    ln_dim = length.(mdl.GridDef.Grids[1:(end÷2)])
    dr_ci = CartesianIndices(tuple(ln_dim...))[dr_temp]
    grid_n = length(ln_dim)
    new_grids = copy(mdl.GridDef.Grids)
    ind_in = (mdl.DR[mdl.Ψ .!= 0])
    ind_in = ind_in[ ind_in .!= 0 ]
    dr_to = CartesianIndices( tuple(ln_dim...) )[ind_in]
    ci_idx = Array{Vector{Int}}(undef,grid_n,4)
    
    for i in 1:grid_n
        
        i_ci = sort(unique(cat(collect.(Tuple.(dr_ci))...,dims=2)[i,:]))
        check_vec = (i_ci[2:end] .== (i_ci[1:end-1] .+ 1))
        idx_pos, seq_ln =  sequence(check_vec)
        seq_ln = seq_ln[check_vec[idx_pos] .== 1] 
        idx_pos = idx_pos[check_vec[idx_pos] .== 1]
        
        # check if there are any sequences of data points AND if there is only one that conatain on last point and point before

        check_major = (!(isempty(seq_ln) | isempty(idx_pos))) & !( ( (i_ci[idx_pos[end]] + seq_ln[end]) == ln_dim[i]) & ( seq_ln[end] == 1 ) & (length(idx_pos) == 1))
        if  check_major

            #Check if last sequence icludes end point of grid

            if (i_ci[idx_pos[end]] + seq_ln[end]) == ln_dim[i] 
                
                #check if last sequence is simply two points neighbouring each other

                if ( seq_ln[end] == 1 )
                    
                    seq_ln = seq_ln[1:end-1]
                    idx_pos = idx_pos[1:end-1]
                    
                else
                    
                    seq_ln[end] -=1
                    
                end
                
            end
            
            if (i_ci[idx_pos[1]]) == 1
                
                if ( seq_ln[end] == 1 )
                    
                    seq_ln = seq_ln[2:end]
                    idx_pos = idx_pos[2:end]
                    
                else
                    
                    seq_ln[1] -=1
                    idx_pos[1] +=1
                    
                end
                
            end
            
            idx_out = Vector{Int}()
            tmp = [range(x,length = y+1) for (x,y) = zip(i_ci[idx_pos], seq_ln )]
            tmp = collect.(tmp)
            append!.([idx_out],tmp)
            idx_out = idx_out[idx_out .∉  [[ 1,length(mdl.GridDef.Grids[2]) ]] ]
            (length(mdl.GridDef.Grids[i]) ∈ i_ci) ? (idx_leave = i_ci) : (idx_leave = [i_ci...,length(mdl.GridDef.Grids[i])])
            idx_leave = idx_leave[idx_leave .∉ [idx_out]]
            ci_idx[i,:] = [idx_leave, idx_out, i_ci[idx_pos], seq_ln]
            
        else
            
            ci_idx[i,:] = [ i_ci, [], [], [] ]
            
        end
        
    end
    
    # isdefined(ci_idx)
    
    if !all(length.(ci_idx[:,1]) .== ln_dim)
        
        tmp = sqrt( *(sum(length.(ci_idx[:,1:2]), dims = 2)...) \ grid_power )
        
        new_ln_dim = Int.(round.(sum(length.(ci_idx[:,1:2]) .* tmp, dims = 2)))
        
        for i in 1:grid_n
            
            
            
            to_i = sort(unique(cat(collect.(Tuple.(dr_to))...,dims=2)[i,:]))
            ci_i = ci_idx[i,:]
            new_grid_i = mdl.GridDef.Grids[i][ci_i[1]]
            
            if !isempty(ci_idx[i,2])   
                
                points_left = new_ln_dim[i] - (length(ci_i[1]) + sum(ci_i[4] .+ 1))
                special = 0.0
                
                iter = 0
                bonus_Ψ  = [any(ci_i[3][m] .<=to_i .<= ci_i[3][m]+ci_i[4][m]) for m=1:length(ci_i[3]) ]
                maxiter = false
                
                let n_points
                    
                    while (true)
                        
                        # points_distro = (ci_i[4] .+ 1 .+special) .* (bonus_Ψ .+ 1))
                        
                        points_distro = (ci_i[4] .+ 1 .+special) .* (bonus_Ψ)
                        n_points = round.(Int, ( (points_left * points_distro ./ sum(points_distro) ) ) )
                        ((sum(n_points) == points_left) | (maxiter)) && break
                        special -= .01 * min(round.(Int,points_left * (ci_i[4] .+ 1 .+special))... )/new_ln_dim[i]
                        iter += 1
                        maxiter = iter == GridDef_maxiter
                        
                    end
                    
                    for j = length.(ci_i[3])
                        
                        k = ci_i[3][j]
                        l = ci_i[4][j]
                        range_i = mdl.GridDef.Grids[i][[k,k+l]]
                        midpoint = sum(range_i)/2
                        g_i = diff(range_i)/(l)
                        n_g_i = diff(range_i) / (n_points[j] + l - 1 * (n_points[j] != 0) )
                        n_grid_part = cumsum(repeat(n_g_i,  n_points[j] + l + 1))
                        n_grid_part .+= midpoint -(sum(n_grid_part) / length(n_grid_part)) 
                        append!(new_grid_i,n_grid_part)
                        
                    end
                    
                end
                
            end

            new_grids[[i,i+grid_n]] = repeat([sort(new_grid_i)],2)
            
        end
        
    end
    
    return(GridDef(mdl.GridDef.VarNames, new_grids))
    
end