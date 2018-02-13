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
    deps = nothing,
    make = nothing
)
