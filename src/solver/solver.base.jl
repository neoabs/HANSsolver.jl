function hans_solver(mdl::Union{ModelInit,Model}, lower::Vector{Float64}=[.975,.975], upper::Vector{Float64}=[1.075,1.075]; method_cube::String="CPU") # , lower = zeros(length(mdl.Prices)), upper = ones(length(mdl.Prices)))
    
    # initialise model
    
    mdl = init_model(mdl)
    results = Optim.optimize(prices -> objective_function(prices, mdl, method_cube), mdl.Prices, Optim.NelderMead())
    # results = optimize( prices -> objective_function(prices, mdl, method_cube), lower, upper, mdl.Prices , Fminbox( NelderMead() ) )
    # results = optimize( prices -> objective_function(prices, mdl, method_cube), mdl.Prices , ParticleSwarm(lower, upper, 12 ) ) 
    
    if (results.minimum < 10^(-8))
        
        printstyled("\n\n\nModel Solution found with precision 10^-8 with respect to value function.\nRunning last iteration to generate contents of Model\n\n)", color=28)
        mdl, new_prices = iterate_mdl(results.minimizer, mdl, method_cube)
        
    end
    
    if (results.minimum >= 10^(-8))
        
        printstyled("\n\n\nModel Solution NOT found with precision 10^-8 with respect to value function.\nRunning last iteration to generate contents of Model\n\n)", color=28)
        mdl, new_prices = iterate_mdl(results.minimizer, mdl, method_cube)
        
    end
    # mdl.Prices = new_prices   
    # HA iteration loop
    # make use of dagger + arrayfire
    # also, make it as function.
    return(results, mdl)
    
end


function hans_solver_dynamic_griding(mdl::Union{ModelInit,Model}, grid_power::Int=2048, lower::Vector{Float64}=[.775,.775], upper::Vector{Float64}=[1.075,1.075]; method_cube::String="CPU") # , lower = zeros(length(mdl.Prices)), upper = ones(length(mdl.Prices)))
    
    # initialise model
    
    mdl = init_model(mdl)

    results = Optim.optimize(prices -> objective_function(prices, mdl, method_cube), mdl.Prices, Optim.NelderMead(), Optim.Options(g_tol=10^-4))
    # results = optimize( prices -> objective_function(prices, mdl, method_cube), lower, upper, mdl.Prices , Fminbox( NelderMead() ) )
    # results = optimize( prices -> objective_function(prices, mdl, method_cube), mdl.Prices , ParticleSwarm(lower, upper, 12 ) ) 
    
    printstyled("\n\n\nModel Solution found for initial Grid.\nRunning last iteration to generate contents of Model, than updating Grid\n\n", color=28)
    mdl, new_prices = iterate_mdl(results.minimizer, mdl, method_cube)
    # @load "mdl_tmp.jlo" results mdl
    print("\n\n")
    
    mdl.GridDef = update_grid(mdl, grid_power)
    # mdl = init_model(mdl)
    
    i = Int(0)

    while i < 12
        
        mdl = init_model(mdl)
        results = Optim.optimize(prices -> objective_function(prices, mdl, method_cube), mdl.Prices , Optim.NelderMead(),
         Optim.Options(g_tol=10.0^(-4 - i)) )
        mdl, new_prices = iterate_mdl(results.minimizer, mdl, method_cube)

        if (results.minimum < 10^(-12))
            
            printstyled("\n\n\nModel Solution found with precision 10^-3 with respect to value function.\nRunning last iteration to generate contents of Model\n\n\n", color=28)
            # mdl, new_prices = iterate_mdl( results.minimizer, mdl, method_cube )
            break
            
        else
            
            printstyled("\n\n\nModel Solution NOT found with precision 10^-3 with respect to value function.\nUpdating Grid and running next iteration\n\n\n\n\n\n", color=28)
            # @save "mdl_tmp.jlo" results mdl
            mdl.GridDef = update_grid(mdl, grid_power)
            i += 1


        end
        
    end
    # mdl.Prices = new_prices   
    # HA iteration loop
    # make use of dagger + arrayfire
    # also, make it as function.
    return(results, mdl)
    
end