"""\nFunction that creates Utils struct from model definition\n# Arguments\n- `mdl::Model`: mutable struct Model.\n- `method_cube::String="CPU"`: the method for the utils cube. Try "CPU", "GPU","Mmap","Function".\n# Examples\n```julia-repl\njulia> execute_cube(my_model, "CPU")\n```\n"""
function execute_cube(mdl::Model,method_cube::String="CPU")
    
    (method_cube == "CPU") && ((cubefun, precompilation) = (cube_CPU, true))
    (method_cube == "GPU") && ((cubefun, precompilation) = (cube_GPU, true))
    (method_cube == "Mmap") && ((cubefun, precompilation) = (cube_Mmap, true))
    (method_cube == "Function") && ((cubefun, precompilation) = (cube_function, false))
    
    ( ! @isdefined cubefun ) && error("1.Method provided for Cube is incorrect. Check for spelling errors.")
    
    
    # precompilation = true

    # if (method_cube == "Function") 
    
    #     precompiletion = false
    
    # end
    
    
    if precompilation == true
        
        (method_cube == "CPU") && (qb = cube_CPU_qb(mdl))
        (method_cube == "GPU") && (qb = cube_GPU_qb(mdl))
        (method_cube == "Mmap") && (qb = cube_Mmap_qb(mdl))
        return( Utils(cubefun,qb) )
        
    end
    
    return( Utils(cubefun) )
    
end

