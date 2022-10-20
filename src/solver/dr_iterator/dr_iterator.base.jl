"""
Function calculates decision rules for given prices and Utils
# Arguments
- `mdl::Model`: Ntuple containing coordinates
# Examples
```julia-repl
julia> iterate_decission_rules(mdl)
```
"""
function iterate_decission_rules(mdl::Model)

    # get number of state variables
    l_dim = length( mdl.GridDef.Grids ) ÷ 2 

    # initialize DR
    mdl.DR = zeros( Int64, *( length.( mdl.GridDef.Grids[1:l_dim] )... ), length( mdl.GridDef.Grids[end] ) )
    
    #precompute VF for given prices and etc:
    precomputeVF(mdl)

    #initialize loop parameters
    iter, no_convergeance = (0, true)
    

    while (no_convergeance)
        
        #there must be a more efficient way to do the below:
        old_vf, old_dr, old_vfalter = copy(mdl.VF), copy(mdl.DR), copy(mdl.VFalter)
        
        #find optimal decission rules/ vf matrix given old DR / old VF
        mdl = dr_CPU(mdl)
        
        #optional afterprocessing
        mdl.VF_afterprocess(mdl)

        # consitent strategy rule
        check1 = old_dr != mdl.DR
        check2 = sum(abs.(old_vf - mdl.VF)) + sum(abs.(old_vfalter - mdl.VFalter)) > 10^-3
        #might concentrate with above in the future. Right now it is divided in case more condition would arrive. 
        no_convergeance = (check1&check2)
        
        #iteration increment
        iter += 1
        
        if (!no_convergeance)

            printstyled("\e[s\e[5G✓\e[u",bold = true, color = :green)
    
        end
        if (iter == vf_iterator_maxiter) 
            
            no_convergeance = false
            printstyled("\e[s\e[5G!\e[u",bold = true, color = :red)
            global DR_punish = true

        end

        
    end


end