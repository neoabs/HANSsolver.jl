function modeltest(mdl::ModelInit,method_cube::String="CPU")
    
    mdl = init_model(mdl)
    mdl.Utils = execute_cube(mdl, method_cube)
    iterate_decission_rules(mdl)
    Ψ_search(mdl)
    new_prices = copy(mdl.MCcondition(mdl))
    push!( mdl.History, tuple(mdl.Prices..., new_prices...) )

    return(mdl)
    
end
function modeltest(mdl::Model,method_cube::String="CPU")
    
    mdl = init_model(mdl)
    mdl.Utils = execute_cube(mdl, method_cube)
    iterate_decission_rules(mdl)
    Ψ_search(mdl)
    new_prices = copy(mdl.MCcondition(mdl))
    push!( mdl.History, tuple(mdl.Prices..., new_prices...) )

    return(mdl)
    
end

