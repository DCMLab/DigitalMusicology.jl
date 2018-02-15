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

# Musical Structures

include("PitchCollections.jl")
@reexport using .PitchCollections

include("Slices.jl")
@reexport using .Slices

include("Grams.jl")
@reexport using .Grams

include("Schemas.jl")
@reexport using .Schemas

# Input and Output

include("Corpora.jl")
@reexport using .Corpora

include("External.jl")
@reexport using .External

end # module
