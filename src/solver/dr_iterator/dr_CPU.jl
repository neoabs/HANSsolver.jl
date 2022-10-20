# Different dispatch for cases where VF alter is a Vector and Array
## Case for Vector:
"""
Function calculates single iteration of Value Function search. 
Updates VF::__`Matrix`__ and VFalter::(either __`Matrix`__ or __`Vector`__ object - depending on alternate state (discrete choice) being a single vector(one value for each status)  )
or an array(single value for each state and status)

# Arguments
- `mdl::Model`: Model
- `vectorORmatrix::Union{Vector{<:Real},Matrix{<:Real}}=mdl.VFalter`: used just to determine which version of algorithm will be used: One for Vector or one for Matrix. Supplied automatically.
# Examples
```julia-repl
julia> dr_CPU(my_mdl) # where my_mdl is Struct Model.
julia> dr_CPU(my_mdl,mymdl.VFalter)
```
"""
function dr_CPU(mdl::Model,vectorORmatrix::Vector{<:Real}=mdl.VFalter)
    
    #initialize etc
    value = view(mdl.VF, :, :)
    decission = view(mdl.DR, :,:)
    υ = view( mdl.VFalter, : )
    l_dim = Int64( floor( length( mdl.GridDef.Grids ) / 2 ) )
    n_dim = tuple( length.( mdl.GridDef.Grids[1: l_dim ] )... )
    
    
    # for each status
    for status = mdl.GridDef.Grids[end]
        
        # initialize value in next period
        # TODO: actually, check if it is correct (seems to be)
        v_tomorrow = value * mdl.λ[status,:]
        
        @Threads.threads for idx = vec(LinearIndices( n_dim )) 
            
            #get cartesian index equivalent 4 linear index idx 
            idxC = CartesianIndices( n_dim )[ idx ]

            #get CIs for Utils selection: today's stays the same, future can be any.
            cis = [ CartesianIndex( idxC, future_ci) for future_ci = CartesianIndices( n_dim ) ]

            # This seems extremely unoptimal. But works so is left for now.
            cis_today = vec( LinearIndices( tuple(repeat([ n_dim... ], 2)...) )[ cis ] )
            u_today = mdl.Utils.f.( CartesianIndex.(cis_today), [status], [mdl] )

            #v get potential VF for given index of state variables
            v_tmp = u_today + mdl.β * v_tomorrow
            #find max
            v,i_d = findmax(v_tmp)
            
            #update for discrete choice
            # shouldn't it be done AFTER VFalter is updated? For consideration.
            v,i_d = υ[status] > v ? (υ[status], 0) : (v, i_d)
            
            #update view
            value[idx, status], decission[idx, status] = ( v, i_d )
            
        end
        
    end

    #Update VF alter (view) for updated VF → needs to be here because of (1)
    mdl.VFalter = zeros(size(mdl.VF))
    υ[:] = mdl.HAconstraint_Alt(mdl)

    #initialize parameters for VFalter search
    iter_fin = 0
    iter=0
    condition = true

    #Search for VFalter for new Model.VF
    # 
    while condition
        
        test_υ = copy(υ) # (1)
        υ[:] = mdl.HAconstraint_Alt(mdl)

        #Inrease precission in the future?
        ( (sum(abs.(υ - test_υ)) < 10^(-6)) | (iter ≥ vf_iterator_maxiter)) && (iter_fin += 1)
        iter +=1
        condition = iter <= 7
        
    end

    if (isa(mdl.VFalter, Vector))

        @Threads.threads for status in mdl.GridDef.Grids[end]
        
            # array_bool = value[:,status] .!= Inf
            # array_bool .*= value[:,status] .!= -Inf
            # array_bool .*= .!isnan.(value[:,status])
            array_bool = value[:,status] .≥ υ[status]
            value[:,status][.!array_bool] .= υ[status]
            decission[:,status][.!array_bool] .= 0
            
        end

    elseif (isa(mdl.VFalter, Matrix))

        @Threads.threads for status in mdl.GridDef.Grids[end]
        
            # array_bool = vf[:,status] .!= Inf
            # array_bool .*= vf[:,status] .!= -Inf
            # array_bool .*= .!isnan.(vf[:,status])
            array_bool = value[:,status] .≥ υ[:,status]
            value[:,status][.!array_bool] .= υ[:,status]
            decission[:,status][.!array_bool] .= 0

        end

    end

end

## Case for Array:

function dr_CPU(mdl::Model,vectorORmatrix::Matrix{<:Real}=mdl.VFalter)
    
    #initialize etc
    value = view(mdl.VF, :, :)
    decission = view(mdl.DR, :,:)
    υ = view( mdl.VFalter, :, :)
    l_dim = Int64( floor( length( mdl.GridDef.Grids ) / 2 ) )
    n_dim = tuple( length.( mdl.GridDef.Grids[1: l_dim ] )... )
    
    
    # for each status
    for status = mdl.GridDef.Grids[end]
        
        # initialize value in next period
        # TODO: actually, check if it is correct
        v_tomorrow = value * mdl.λ[status,:]
        
        @Threads.threads for idx = vec(LinearIndices( n_dim )) 
            
            idxC = CartesianIndices( n_dim )[ idx ]

            cis = [ CartesianIndex( idxC, future_ci) for future_ci = CartesianIndices( n_dim ) ]
            cis_today = vec( LinearIndices( tuple(repeat([ n_dim... ], 2)...) )[ cis ] )
            u_today = mdl.Utils.f.( CartesianIndex.(cis_today), [status], [mdl] )
            v_tmp = u_today + mdl.β * v_tomorrow
            v,i_d = findmax(v_tmp)
            
            #TODO: MAS - multi alternate state
            v,i_d = υ[idx,status] > v ? (υ[idx,status], 0) : (v, i_d)
            
            value[idx, status], decission[idx, status] = ( v, i_d )
            
        end
        
    end

    #TODO: MAS - multi alternate state
    mdl.VFalter = zeros(size(mdl.VF))
    υ[:,:] = mdl.HAconstraint_Alt(mdl)

    iter_fin = 0
    iter=0
    condition = true

    #Search for VFalter for new Model.VF
    while condition
        
        test_υ = copy(υ) # (1)
        υ[:] = mdl.HAconstraint_Alt(mdl)

        #Inrease precission in the future?
        ( (sum(abs.(υ - test_υ)) < 10^(-6)) | (iter ≥ vf_iterator_maxiter)) && (iter_fin += 1)
        iter +=1
        condition = iter <= 7
        
    end

    if (isa(mdl.VFalter, Vector))

        @Threads.threads for status in mdl.GridDef.Grids[end]
        
            # array_bool = value[:,status] .!= Inf
            # array_bool .*= value[:,status] .!= -Inf
            # array_bool .*= .!isnan.(value[:,status])
            array_bool = value[:,status] .≥ υ[status]
            value[:,status][.!array_bool] .= υ[status][.!array_bool]
            decission[:,status][.!array_bool] .= 0
            
        end

    elseif (isa(mdl.VFalter, Matrix))

        @Threads.threads for status in mdl.GridDef.Grids[end]
        
            # array_bool = vf[:,status] .!= Inf
            # array_bool .*= vf[:,status] .!= -Inf
            # array_bool .*= .!isnan.(vf[:,status])
            array_bool = value[:,status] .≥ υ[:,status]
            value[:,status][.!array_bool] .= υ[:,status][.!array_bool]
            decission[:,status][.!array_bool] .= 0

        end
        
    end

end

"""
Function pre-calculates VF and VFalter. For VF it assumes that agents do not switch either state or status. Thus for low-endowment statuses it will be too low and vice versa for high-endowment. 
State switching was not included to simplify (and speed up) calculations. 
"""
function precomputeVF(mdl::Model)
    
    # initialize stuff
    vf = view(mdl.VF,:,:)
    ndim = length.(mdl.GridDef.Grids[1:(end-1)] ) 
    statuses = mdl.GridDef.Grids[end]
    cis = CartesianIndices( tuple( ndim[1:(length(ndim)÷2)]... ) )
    cis = CartesianIndex.(cis,cis)

    ## not sure if multithreading here helps:
    # most operations are basic algebra so they are multithreaded anyway.
    # In the future might test for MT and ST here.
    @Threads.threads for status = statuses
        
        u = mdl.Utils.qb[status][cis]
        vf_i = copy(u)
        
        iter = 0
        condition = true
        while condition
            
            test_vf = copy(vf_i)
            vf_i *= mdl.β
            vf_i += u
            # array bool is necessary to calculate convergeance criterion for when Inf/-Inf and others are present
            array_bool = vf_i .!= Inf
            array_bool .*= vf_i .!= -Inf
            array_bool .*= .!isnan.(vf_i)
            vf_check = abs.(vf_i - test_vf)
            sum( vf_check .* array_bool) < 10^(-6) && (iter += 1)
            condition = iter <= 7
            
        end

        # vectorize and write
        vf[:,status] = vec(vf_i)

    end

    # Compute VFalter for precomputed VF
    mdl.VFalter = zeros(size(mdl.VF))
    mdl.VFalter = mdl.HAconstraint_Alt(mdl)
    υ = view( mdl.VFalter, :,: )

    iter_fin = 0
    iter=0
    condition = true

    #Search for VFalter for new Model.VF
    while condition
        
        test_υ = copy(υ) # (1)
        υ[:] = mdl.HAconstraint_Alt(mdl)

        #Inrease precission in the future?
        ( (sum(abs.(υ - test_υ)) < 10^(-6)) | (iter ≥ vf_iterator_maxiter)) && (iter_fin += 1)
        iter +=1
        condition = iter <= 7
        
    end

    # change strange values into some more reasonable

    if (isa(mdl.VFalter, Vector))

        @Threads.threads for status in statuses
        
            array_bool = vf[:,status] .!= Inf
            array_bool .*= vf[:,status] .!= -Inf
            array_bool .*= .!isnan.(vf[:,status])
            array_bool .*= vf[:,status] .> υ[status]
            vf[:,status][.!array_bool] .= υ[status]
            
        end

    elseif (isa(mdl.VFalter, Matrix))

        @Threads.threads for status in statuses
        
            array_bool = vf[:,status] .!= Inf
            array_bool .*= vf[:,status] .!= -Inf
            array_bool .*= .!isnan.(vf[:,status])
            array_bool .*= vf[:,status] .≥ υ[:,status]
            vf[:,status][.!array_bool] .= υ[:,status][.!array_bool]

        end
        
    else

        error("Precalculation of VF failed")

    end

end
