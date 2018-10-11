include("makelocal.jl")

deploydocs(
    repo = "github.com/DCMLab/DigitalMusicology.jl",
    target = "build",
    julia = "0.7",
    deps = nothing,
    make = nothing
)
