using DemoInertiaPreprocess
using Documenter

DocMeta.setdocmeta!(DemoInertiaPreprocess, :DocTestSetup, :(using DemoInertiaPreprocess); recursive=true)

makedocs(;
    modules=[DemoInertiaPreprocess],
    authors="Krishna Bhogaonker",
    sitename="DemoInertiaPreprocess.jl",
    format=Documenter.HTML(;
        canonical="https://00krishna.github.io/DemoInertiaPreprocess.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/00krishna/DemoInertiaPreprocess.jl",
    devbranch="main",
)
