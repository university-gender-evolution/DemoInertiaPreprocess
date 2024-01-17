


function merge_new_um_data_into_single_file(filepath::String, newfilename::String)

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
        rename!(tdf, [:campus, :name, :jobcode, :orgname, :ftr, :basis, :fraction, :gf])

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
            #@debug("head: $(first(tdf, 5))")
            append!(combined_df, tdf, promote=true)
            @debug("appended file to combined dataframe.")
        end
    end

    
    CSV.write(joinpath(filepath, newfilename), combined_df)
    @debug("wrote file to directory.")
    @debug("closing log.")


end
