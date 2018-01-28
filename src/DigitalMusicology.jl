module DigitalMusicology

# Currently, all names from submodules are used.
# Maybe this should be done selectively in some cases.
using Reexport

include("Pitches.jl")
@reexport using .Pitches

include("PitchOps.jl")
@reexport using .PitchOps

include("PitchCollections.jl")
@reexport using .PitchCollections

include("Slices.jl")
@reexport using .Slices

end # module
