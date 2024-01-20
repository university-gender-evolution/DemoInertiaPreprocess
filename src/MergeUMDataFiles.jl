


function merge_new_um_data_into_single_file(filepath::String, newfilename::String; to_csv::Bool=true)

    # Start the logging stuff
    logger = TeeLogger(
            ConsoleLogger(stderr),
            FormatLogger(open("logfile_merge_um_data.txt", "w")) do io, args
            # Write the module, level and message only
                println(io, args._module, " | ", "[", args.level, "] ", args.message)
            end )
    
    global_logger(logger)

    @debug("file path is: $filepath")
    @debug("file name is: $newfilename")

    # first get all files in the directory into a Vector

    file_list = String[]

    if ispath(filepath)
        file_list = filter(endswith(".csv"), readdir(filepath))
        @debug("file path is valid.")
    else
        throw(ArgumentError("The directory path provided was not a valid path. Please correct the path and try again."))
    end

    # remove the newfilename from the file list if it exists.
    deleteat!(file_list, file_list .== newfilename)
    @debug("file list is:  $file_list")
    
    # setup the combined dataframe container 
    combined_df = DataFrame()

    # iterate over file_list
    for f in file_list
    # for each file in list, read the data into a dataframe.
        @debug("file opened: $(joinpath(filepath, f))")
        tdf = DataFrame(CSV.File(joinpath(filepath, f)))
        rename!(tdf, [:campus, :name, :jobdesc, :orgname, :ftr, :basis, :fraction, :gf])

        # append a column to the dataframe for the year, university 
        reg = r"[0-9]+"
        m = match(reg, f, 9)
        tdf[:, :year] .= parse(Int64, m.match)
        @debug("processed year: $(parse(Int64, m.match))")
        # append the new dataframe to the full dataframe 
        if isempty(combined_df)
            combined_df = tdf
            @debug("Created new combined dataframe.")
        else
            append!(combined_df, tdf, promote=true)
            @debug("appended file to combined dataframe.")
        end
    end

    for c in [:campus, :name, :jobdesc, :orgname]
        combined_df = transform(combined_df, c => ByRow(passmissing(lowercase)) => c)
    end
    

    @debug("replace missing values in orgname and jobdesc.")

    if to_csv    
        CSV.write(newfilename, combined_df)
        @debug("wrote files to directory.")
        @debug("closing log.")
    end

    return combined_df
end


function _extract_unique_department_prof_names_from_new_um_data(tdf::DataFrame; to_csv=true, 
            include_list=["professor", "assoc professor", "asst professor"], 
            exclude_list=[])
    
    logger = TeeLogger(
            ConsoleLogger(stderr),
            FormatLogger(open("logfile_unique_names.txt", "w")) do io, args
            # Write the module, level and message only
                println(io, args._module, " | ", "[", args.level, "] ", args.message)
            end )
    
    global_logger(logger)
    # First sort the dataframe by name. I am really trying to remove the same names.


    @debug("loaded the file to dataframe")
    
    tdf = sort(tdf, [:name])

    @debug("sorted file by name")

    # Then I want to get the unique name and department combos. This will remove
    # the same names from year to year.    
    tdf = unique(tdf, [:name, :orgname])
    @debug("produced unique name and department combos: \n $(first(tdf, 5))")
    # Next I have to extract only professors. I don't want to look at names that  
    # are not professors. I will probably need to tune this. I can search for 
    # just professors and such. 

    tdf = transform(tdf, :jobdesc => ByRow(passmissing(lowercase)) => :jobdesc)
    @debug("lowercased all of the job descriptions.")
    
    replace!(tdf.jobdesc, missing => "")
    @debug("produced unique name and department combos")

    tdf = filter(:jobdesc => n -> any(occursin.(include_list, n)), tdf)
    @debug("filtered to include data on the include list.")
    
    tdf = filter(:jobdesc => n -> !any(occursin.(exclude_list, n)), tdf)
    @debug("filtered out data on the exlude list.")
    
    tdf = sort(tdf, [:campus, :orgname, :jobdesc])
    if to_csv    
        CSV.write("unique_name_depts.csv", tdf)
        @debug("wrote file to directory.")
        @debug("closing log.")
    end

    return tdf
end


function _extract_unique_department_prof_names_from_new_um_data(fname::String; to_csv=true, 
            include_list=["professor", "assoc professor", "asst professor"],
            exclude_list=[])


    tdf = DataFrame(CSV.File(fname))

    res = _extract_unique_department_prof_names_from_new_um_data(tdf; to_csv=to_csv, 
            include_list=include_list, exclude_list=exclude_list)    

    return res
    
end