### Global variables
global vf_iterator_maxiter = 400
global Ψ_precission = 10^-2
global Ψ_maxiter = 400
global Ψ_punish_degree = 1.0
global DR_punish_degree = 0.5
global GridDef_maxiter = 10^5

### Custom structs

struct GridDef
    
    VarNames::NTuple{N,Symbol} where N
    Grids::Vector{T} where T #Union{AbstractRange,AbstractVector{<:Real},,AbstractVector{<:Integer}}
    GridDef(VarNames,Grids) = (length(VarNames) != length(Grids)) ? error("variables and grid dimmension do not match") : new(VarNames,Grids)
    
end

mutable struct Utils
    
    f::Function
    qb::Union{Vector{Array{Float64}}, Nothing}
    Utils() = new() # This one is for Init phase
    Utils(f) = new(f,nothing)
    Utils(f,qb) = new(f,qb)

end

struct ModelInit{T<:Real}
    
    Prices::Vector{T}
    GetAP::Function
    GridDef::GridDef
    λ::Matrix{T}
    β::T
    # Statvar::AbstractString
    HAutility::Function
    HAconstraint::Function
    HAconstraint_Alt::Function
    # VFstart::Array{T}
    # VFalter::Vector{T}
    VF_afterprocess::Function
    # Ψᵢₙᵢₜ::Array{T}
    alternate_return::Function
    MCcondition::Function
    InitParams::Function
    
end

mutable struct Model{T<:Real}
    
    Prices::Vector{T}
    AddPrices::Vector{T}
    GetAP::Function
    GridDef::GridDef
    λ::Matrix{T}
    β::T
    # Statvar::Char # statvar must start with 1, Integer only
    HAutility::Function
    Utils::Utils
    HAconstraint::Function
    HAconstraint_Alt::Function
    # VFstart::Array{T}
    VF::Matrix{T}
    DR::Matrix{<:Integer}
    VFalter::Union{Vector{T},Matrix{T}}
    VF_afterprocess::Function
    Ψ::Matrix{T}
    # Ψᵢₙᵢₜ::Array{T}
    Λ::Vector{T}
    alternate_return::Function
    MCcondition::Function
    History::Vector{NTuple{N,Float64}} where N
    InitParams::Function
    
end

