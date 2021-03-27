function alt_constraint(mdl::Model)
    
    R, Rᴸ = mdl.Prices[1:2]
    ω, τ = mdl.AddPrices

    #initialize VFalter if not done already
    size(mdl.VFalter) != size(mdl.VF) && (mdl.VFalter = zeros(Float64, size(mdl.VF)))
    
    #Indices for get_vars
    ndim = length.( mdl.GridDef.Grids[1:(end-1)] ) 
    cins = CartesianIndices( tuple( ndim[1:(length(ndim)÷2)]... ) )
    # cins = CartesianIndex.(cins,cins)

    #utility today if defaulted
    #TODO: This does not have to be calculated here, each call. It can be precalculated once after prices change.Find solution and fix it
    u_alter = zeros(Float64, size(mdl.VF) )
    vfalter = view(mdl.VFalter,:,:)
    for status = mdl.GridDef.Grids[end] 
    
        @Threads.threads for idx = cins

            v = get_vars( (Tuple(CartesianIndex(idx,idx))... ,status), mdl_init.GridDef)
            dᴿ =  v.l₁ * δᶠ * δˡ;
            
            #Consumption today if defaulted
            c = max( (( v.d₁ - dᴿ) * ( ρ * R / 𝜋) + ( 1 - τ ) * ω * (v.λᵢ==1) + ϐ * (v.λᵢ==2)), ϐ)
            u_alter[LinearIndices(cins)[idx],status] = mdl.HAutility(c, true,true,false)
            
        end
    
    end 

    c_if_defaulted = Χ * [(( 1 - τ ) * ω), ϐ]
    vfalter[:,:] = vfalter[:,:] - u_alter # TODO: se todo above

    # vfalter = mdl.HAutility.( c_if_defaulted, 0.0 ) +
    vfalter[:,:] = u_alter .+
        mdl.β * (
        (1 - ζ) * ( ( mdl.λ * mdl.HAutility.(c_if_defaulted, true, true, false))' .+
        mdl.β * ( vfalter[:,:] * mdl.λ' ) ) .+ ζ * ( mdl.λ * mdl.VF[1,:] )'
        )

    return(mdl.VFalter)

end