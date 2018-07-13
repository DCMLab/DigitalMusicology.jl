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

# Input and Output

include("io/MidiFiles.jl")
@reexport using .MidiFiles

include("Corpora.jl")
@reexport using .Corpora

include("External.jl")
@reexport using .External

end # module
