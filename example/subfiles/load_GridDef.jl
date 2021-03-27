function get_grids1()

    r = ( 1/β )
    w = 1/(Lₛ * r * 𝜋)
    t = (1 - Lₛ) * ϐ / ( Lₛ * w)
    loan_max =  (w * (1 - t) - ϐ) / ((r - 1) * w * (1 - t)) 

    loan_grid_points = Int(32)

    b = 0.25
    a = ( - log( loan_max ) + log( b )) / ( ( loan_grid_points - 1 ) * log( 1 - δᶠ))

    function GridGen(x::Int64,a_::Float64=a, b_::Float64=b)

        return (b_ * ( (1-δᶠ )^(-a_*x) ) ) 

    end


    loan_grid = Vector{Float64}([0.0])
    push!(loan_grid, [ GridGen(x) for x in 1:(loan_grid_points-1) ]...)

    depo_grid_points = Int(32) 
    depo_grid = Vector{Float64}([0.0])
    push!(depo_grid, [ GridGen(x) for x in 1:(depo_grid_points-1) ]...)

    return(loan_grid, depo_grid)

end


function get_grids2(x::Int)

    r = ( 1/β )
    w = 1/(Lₛ * r * 𝜋)
    t = (1 - Lₛ) * ϐ / ( Lₛ * w)
    loan_max =  (w * (1 - t) - ϐ) / ((r - 1) ) #* w * (1 - t)) 
    depo_max = loan_max
    loan_grid_points = Int(x)

    # "distance between two neighbouring grid points. Used in utility function"
    𝔤 = loan_max / (loan_grid_points-1)
    loan_grid = 0:𝔤:loan_max

    # loan_grid = (0:(loan_grid_points - 1))*(loan_max/(loan_grid_points - 1))
    depo_grid_points = Int(x) 

    𝔤 = depo_max / (depo_grid_points-1)
    depo_grid = 0:𝔤:loan_max

    return(loan_grid, depo_grid)

end

function get_grids3()

    r = ( 1/β )
    w = 1/(Lₛ * r * 𝜋)
    t = (1 - Lₛ) * ϐ / ( Lₛ * w)
    loan_max = 1.16 * (w * (1 - t) - ϐ) / ((r - 1) * w * (1 - t)) 
    depo_max = loan_max
    loan_min =  68.0
    depo_min = loan_min
    loan_grid_points = Int(32)

    loan_grid = [0,collect( range(loan_min, loan_max, length = (loan_grid_points) ))... ] 

    # loan_grid = (0:(loan_grid_points - 1))*(loan_max/(loan_grid_points - 1))
    depo_grid_points = Int(32)

    depo_grid = [0,collect( range(loan_min, depo_max, length = (depo_grid_points) ))... ] 

    return(loan_grid, depo_grid)

end

loan_grid, depo_grid = get_grids2(32)
# 

## Set starting prices (vector Real):

## Define Grid. Run if have any questions (uncomment first):
# ?help GridDef
## make use of build in function from HANS_utilities:

grid_def = make_dimmensions( ["d", "l","λᵢ"], [ depo_grid , loan_grid, Int.([1, 2]) ])
