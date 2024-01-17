using DemoInertiaPreprocess
using Test
using TestItems


@testitem "[JuliaGendUniv] environment setup" begin
    using DemoInertiaPreprocess
    cd(@__DIR__)
    @show pwd()
    ENV["JULIA_DEBUG"] = "all"
    filepath = "/drives/lakshmi/Dropbox/sandbox/julia_gend_univ/data/new_um_data/raw_data_um_files"
    fn = "test_combine.csv"
    DemoInertiaPreprocess.merge_new_um_data_into_single_file(filepath, fn)
end