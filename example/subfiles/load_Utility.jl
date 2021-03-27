
function utility(consumption::Float64,new_debt::Bool,reserve::Bool,tozero_l::Bool)

    #Put here Your Favorite Utility Function
    check1 = ((new_debt) | tozero_l)
    check2 = reserve
    check3 = consumption > 0
    ( check1 & check2 & check3) ? ( return( (consumption ^ (1 - σ)) / (1 - σ) ) ) : ( return(-Inf) )

end