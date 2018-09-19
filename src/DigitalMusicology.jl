module DigitalMusicology

# Currently, all names from submodules are used.
# Maybe this should be done selectively in some cases.
using Reexport


# Helpers

include("Helpers.jl")

include("GatedQueues.jl")

# Basics

include("Pitches.jl")
@reexport using .Pitches

include("PitchOps.jl")
@reexport using .PitchOps

include("Timed.jl")
@reexport using .Timed

include("Events.jl")
@reexport using .Events

include("Meter.jl")
@reexport using .Meter
# Musical Structures

include("PitchCollections.jl")
@reexport using .PitchCollections

include("Notes.jl")
@reexport using .Notes

include("Slices.jl")
@reexport using .Slices

include("Grams.jl")
@reexport using .Grams

#extension
include("Distributions.jl")
@reexport using .Distributions

include("MidiTools2.jl")
@reexport using .MidiTools2

include("Contour.jl")
@reexport using .Contour

# Input and Output

include("io/MidiFiles.jl")
@reexport using .MidiFiles

include("Corpora.jl")
@reexport using .Corpora

include("External.jl")
@reexport using .External

#=matr = read(matopen("keysomdata.mat"),"somw")
for i = 7:12 ,  j = 1:36 ,  k = 1:24
    println("vsom[",i,",",j,",",k,"] = " , matr[i,j,k])
end 
matr = read(matopen("keysomdata.mat"),"somw")
h5write("data.h5","datasom",matr)
h5read("data.h5","datasom",(10,10,10))
=#
end # module
