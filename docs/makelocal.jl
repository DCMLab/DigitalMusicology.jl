import Pkg; Pkg.activate(@__DIR__);
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
