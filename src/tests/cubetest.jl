function cubetest(mdl::ModelInit,method_cube::String="CPU")
    
    mdl = init_model(mdl)
    mdl.Utils = execute_cube(mdl, method_cube)

    v1 = [1,1,1,1,1]
    v2 = [1,1,1,1,2]
    v3 = Int.(floor.( length.( mdl.GridDef.Grids ) / 2 ))
    v4 = push!(length.( mdl.GridDef.Grids[1:( length(mdl.GridDef.Grids) - 1 ) ] ),1 )
    v5 = length.( mdl.GridDef.Grids )
    test_val = Vector{Vector{Int}}([v1, v2, v3, v4, v5])

    out = Vector{Float64}()
    v = [v1,v2,v3,v4,v5]
    for v = test_val

        push!(out, mdl.Utils.f(v, mdl))

    end

    return( mdl.Utils.f.(v, [mdl]) )
    # return(out)

end

