function budget_constraint(ind_vec::NTuple{N,<:Integer}, mdl::Model, add_args = nothing) where N 

    R,Rᴸ = mdl.Prices[1:2]
    ω, τ = mdl.AddPrices
    v = get_vars(ind_vec, mdl.GridDef)
    #l₁, l₂, d₁, d₂
    # function c = ... . If negative it means that this selection is invalid
    #TODO:fix below (lambdas are state (emp/unemp) variables)
    Δₗ = v.l₂ - (1 - δᶠ) * v.l₁ * ( (Rᴸ) / 𝜋 )
    dᴿ = v.d₂ - v.l₂ * δᶠ * δˡ ≥ 0

    𝔠 = v.d₁ * ( ρ * R / 𝜋) + ( 1 - τ ) * ω * (v.λᵢ==1) + ϐ * (v.λᵢ==2) + Δₗ -
    δᶠ * v.l₁ * ( (Rᴸ) / 𝜋 ) - v.d₂

    # C_ deposit requirement:
    c_min = max(0.0, ( ( 1 - τ ) * ω * (v.λᵢ==1) + ϐ * (v.λᵢ==2) + v.d₁ * ( ρ * R / 𝜋) -
                    - δᶠ * v.l₁ * ( (Rᴸ) / 𝜋 ) ) )
    c = min(c_min,𝔠) + ( 𝔠 - min(c_min,𝔠) ) * ξ 

    tozero_l = (ind_vec[2] - 1) == ind_vec[4]
    # tozero_d = (ind_vec[1] - 1) == ind_vec[3]
    return(c,Δₗ≥0,dᴿ,tozero_l)

end