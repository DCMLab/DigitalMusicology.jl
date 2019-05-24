import Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

using Documenter, DigitalMusicology

makedocs(
    modules = [DigitalMusicology],
    format = :html,
    sitename = "DigitalMusicology.jl",
    pages = [
        "Introduction" => "index.md",
        "Development" => "develop.md",
        "Pitches" => "pitches.md",
        "Reference" => "reference.md"
    ]
)
