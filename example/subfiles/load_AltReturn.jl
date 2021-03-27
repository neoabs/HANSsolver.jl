function alt_return(mdl::Model)
    
    Ψₙₑᵤ = copy(mdl.Λ' * ζ * mdl.λ)
    Λₙₑᵤ = copy(vec( sum( ((mdl.DR .== 0) .* mdl.Ψ * mdl.λ ), dims = 1 ) + mdl.Λ' * ( 1 - ζ ) * mdl.λ) )
    mdl.Ψ = copy(zeros(size(mdl.Ψ)))
    mdl.Ψ[1,:] = copy(Ψₙₑᵤ)
    mdl.Λ = copy(Λₙₑᵤ)
    return( mdl.Ψ, mdl.Λ)
    
end