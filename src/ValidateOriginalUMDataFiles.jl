






function extract_unique_department_prof_names_from_original_um_data(tdf::DataFrame; to_csv=true, 
            include_list=["professor", "assoc professor", "asst professor"], 
            exclude_list=[])
            
    
    logger = TeeLogger(
            ConsoleLogger(stderr),
            FormatLogger(open("logfile_original_um_dept_jobdesc.txt", "w")) do io, args
            # Write the module, level and message only
                println(io, args._module, " | ", "[", args.level, "] ", args.message)
            end )
    
    global_logger(logger)


    @debug("loaded the file to dataframe")
    

    @debug("column names are: $(names(tdf))")

    tdf = sort(tdf, [:name])
        
    tdf = unique(tdf, [:name, :orgname])
    @debug("produced unique name and department combos: \n $(first(tdf, 5))")

    tdf = transform(tdf, :jobdes => ByRow(passmissing(lowercase)) => :jobdes)
    @debug("lowercased all of the job descriptions.")
    
    replace!(tdf.jobdes, missing => "")
    @debug("produced unique name and department combos")

    tdf = filter(:jobdes => n -> any(occursin.(include_list, n)), tdf)
    @debug("filtered to include data on the include list.")
    
    tdf = filter(:jobdes => n -> !any(occursin.(exclude_list, n)), tdf)
    @debug("filtered out data on the exlude list.")
    
    tdf = sort(tdf, [:orgname, :jobdes])
    if to_csv    
        CSV.write("original_um_unique_depts_professors.csv", tdf)
        @debug("wrote file to directory.")
        @debug("closing log.")
    end

    return tdf

end;



function extract_unique_department_prof_names_from_original_um_data(file_name::String; to_csv=true, 
    include_list=["professor", "assoc professor", "asst professor"], 
    exclude_list=[])

    if ispath(file_name)
        @debug("file path is valid.")
    else
        throw(ArgumentError("The directory path provided was not a valid path. Please correct the path and try again."))
    end

    tdf = DataFrame(StatFiles.load(file_name))

    disallowmissing!(tdf, error=false)

    res = extract_unique_department_prof_names_from_original_um_data(tdf; to_csv=to_csv, 
            include_list=include_list, exclude_list=exclude_list )
    
    return res
end