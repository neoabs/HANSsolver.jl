function additional_prices(mdl::Union{Model,ModelInit})

    R,Rᴸ = mdl.Prices
    ω = (Lₛ * ( 1 + (1-ρ) * R) )^-1
    τ = (ϐ / ω) * (1 - Lₛ) / Lₛ

    return([ω,τ])

end