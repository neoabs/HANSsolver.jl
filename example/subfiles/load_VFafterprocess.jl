function nonnaivebanks(mdl::Model)
    
    decision = view(mdl.DR,:,:)
    value = view(mdl.VF,:,:)
    default_id =  [0] #[-(1:size(mdl.VF,1))...]
    check = true
    
    while check
        
        tmp = LinearIndices( decision[:,1] )[findall( all(decision .∈ [default_id], dims = 2 ) )]
        check = !(all(tmp .∈ [default_id]))
        check && append!(default_id, tmp[(tmp .∈ [default_id]) .== false])
        
    end
    
    if (length(default_id) > 1)
        
        decision[default_id[2:end],:] .= 0
        value[default_id[2:end],:] .= mdl.VFalter[default_id[2:end],:]
        
    end
    
end