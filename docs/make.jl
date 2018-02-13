using Documenter, DigitalMusicology

makedocs(
    modules = [DigitalMusicology],
    format = :html,
    sitename = "DigitalMusicology.jl",
    pages = [
        "Introduction" => "index.md",
        "Reference" => "reference.md"
    ]
)

deploydocs(
    repo = "github.com/DCMLab/DigitalMusicology.jl",
    target = "build",
    julia = "0.6"
    deps = nothing,
    make = nothing
)
