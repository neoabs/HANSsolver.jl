function clear_marketing(mdl::Model)
    
    Ψ = mdl.Ψ
    R,Rᴸ = mdl.Prices[ 1:2 ]
    T = mdl.DR
    ω, τ = mdl.AddPrices[ 1:2 ]
    grids = mdl.GridDef.Grids[ 1 : (length(mdl.GridDef.Grids)÷2) ]
    push!(grids,mdl.GridDef.Grids[end])
    grid_names = mdl.GridDef.VarNames[ 1 : (length(mdl.GridDef.Grids)÷2) ]
    grid_names = (grid_names...,mdl.GridDef.VarNames[end])
    (d₁, l₁, λᵢ) = (1, 2, 3)
    #     #Aggregate
    Lᴰ = 0.0
    L= 0.0 # Debt before defaults
    V = 0.0 #Claimed wages
    Vᴰ = 0.0 #Claimed deposits
    D = 0.0 # Deposits before defaults
    
    cube = CartesianIndices( tuple( length.(grids)...))
    
    for idx = eachindex(T)
        
        if (T[idx] == 0)
            
            Lᴰ += Ψ[idx] * grids[l₁][ cube[idx][l₁] ]
            Vᴰ  += Ψ[idx] * grids[d₁][ cube[idx][d₁] ]
            V  += Ψ[idx] * (grids[λᵢ][ cube[idx][λᵢ] ] == 1) * ( ( ( 1 - τ ) * ω ) - ϐ)
            
        else
            
            #Tutaj pomyślec czy nie powinno być  T[idx] - sprawdzić z równaniami poniżej 
            L  += Ψ[idx] * grids[l₁][ cube[T[idx]][l₁] ]
            D  += Ψ[idx] * grids[d₁][ cube[T[idx]][d₁] ]
            
        end
        
    end
    
    V += Vᴰ

    B = D - (L - Lᴰ) - V
    
    #     # Solve et Coalgua
    function sys_of_eqs(Rates::Vector{T}) where T<:Real
        
        R, Rᴸ = Rates
        F = zeros(2)
        # Commercial Banks:
        F[1] = (L - Lᴰ) * Rᴸ  +  ( Lₛ * ( ρ - 1 )  +  B  -  ( D - Vᴰ )*ρ ) * R  + V 
        # Central Bank:
        F[2] = (ρ * ( R/𝜋 ) ) * ( D - Vᴰ )  +  ((1 + R * (1-ρ) )^(-1))  -  (L - Lᴰ) * δᶠ * ( Rᴸ/𝜋 )  +  (L - (L - Lᴰ) * (1 - δᶠ) ) - (V - Vᴰ) - D - 1
        
        return(F)
        
    end
    
    function mx_of_J(Rates::Vector{T}) where T<:Real
        
        R, Rᴸ = Rates
        J = zeros(2,2)
        J[1,1] = ( Lₛ * ( ρ - 1 )  +  B  -  ( D - Vᴰ )*ρ )
        J[2,1] = (ρ /𝜋)  * D - ( R^(-2) ) 
        J[1,2] = (ρ * ( 1/𝜋 ) ) * ( D - Vᴰ )  -  (1 - ρ) / ((1 + R * (1-ρ) )^2)
        J[2,2] = (L - Lᴰ) * δᶠ * ( 1/𝜋 )
        return(J)
        
    end  
    
    # Rates = nlsolve(sys_of_eqs, mx_of_J, [R,Rᴸ], method = :newton).zero
    Rates = nlsolve(sys_of_eqs, [R,Rᴸ], method = :newton).zero
    return(Rates)
    
end