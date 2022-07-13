function Ψ_search(mdl::Model)
   
    tm = mdl.DR
    mdl.Ψ = zeros( Float64, size(mdl.VF) )
    # Probabilities = ones(t_V,2)
    mdl.Λ = vec( (mdl.λ^200)[initial_point,:] )
    
    not_converging = true
    check = 0
    iter = 0

    while not_converging
        
        Λᴼˡᵈ, Ψᴼˡᵈ = copy(mdl.Λ), copy(mdl.Ψ)

        # firstly idx = 0
        mdl.Ψ, mdl.Λ = mdl.alternate_return(mdl)
 
        # secondly idx ≥ 1
        indices = unique(mdl.DR)
        indices = indices[indices .> 0]

        # Threads.@threads 
        for idx = indices
            # for idx = LinearIndices(mdl.Ψ[:,1]) # 4 debug only
            
            mdl.Ψ[idx,:] += vec(sum((tm .== idx) .* Ψᴼˡᵈ * mdl.λ, dims = 1))
            
        end

        #aftercscalling
           
        scale = 1/(sum(mdl.Ψ)+sum(mdl.Λ))
        mdl.Ψ *= scale
        mdl.Λ *= scale

        #CONVERGEANCE CRITERION
        con_val = (sum(abs.(mdl.Λ - Λᴼˡᵈ) ) + sum(abs.(mdl.Ψ - Ψᴼˡᵈ)))
        iter +=1

        if (con_val < Ψ_precission)
            
            not_converging = check < 7
            check += 1
            not_converging || printstyled("\e[s\e[6G✓\e[u",bold = true, color = :green)

        elseif (iter == Ψ_maxiter)

            not_converging = false
            printstyled("\e[s\e[6G!\e[u",bold = true, color = :red)
            global Ψ_punish = true

        end 
        
    end
    

 
    
end