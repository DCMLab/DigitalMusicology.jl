using Documenter, DigitalMusicology

makedocs(
    modules = [DigitalMusicology],
    format = :html,
    sitename = "DigitalMusicology.jl",
    pages = [
        "Introduction" => "index.md",
        "Development" => "develop.md",
        "Reference" => "reference.md"
    ]
)

deploydocs(
    repo = "github.com/DCMLab/DigitalMusicology.jl",
    target = "build",
    julia = "1.0",
    deps = nothing,
    make = nothing
)
