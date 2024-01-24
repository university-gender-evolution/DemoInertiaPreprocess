module DemoInertiaPreprocess

using DataFrames
using CSV
using Plots
using StatsPlots
using StatFiles
using Pipe, StatsBase, Chain
using DataFramesMeta
using Logging, LoggingExtras
using Dates


include("MergeNewUMDataFiles.jl")
include("ValidateOriginalUMDataFiles.jl")

export merge_new_um_data_into_single_file, 
        extract_unique_department_prof_names_from_old_um_data














end
