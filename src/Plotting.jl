module Plotting

using ...DigitalMusicology

export pianoroll, pianoroll!

# using Plots

# Piano Roll
# ==========

function note_to_shape(on, off, pitch)
    yl = pitch - 0.5
    yu = pitch + 0.5
    Shape([on, off, off, on], [yl, yl, yu, yu])
end

note_to_shape(n::Note{P,T}) where {P,T} =
    let pitch = convert(Int, pitch(n))
        yl    = pitch - 0.5
        yu    = pitch + 0.5
        on    = onset(n)
        off   = offset(n)
        Shape([on, off, off, on], [yl, yl, yu, yu])
    end

"""
    pianoroll(onsets, offsets, pitches; kwargs...)

Plots notes as a pianoroll using Plots.jl.
"""
function pianoroll end

"""
    pianoroll!(onsets, offsets, pitches; kwargs...)

Plots notes as a pianoroll using Plots.jl.
"""
function pianoroll! end

# @userplot PianoRoll

# # TODO: make the recipe work.
# # What works is plotting shapes directly:
# #   plot(map(note_to_shape, ons, offs, pitches), ...)
# # but it does not work when used in a recipe:
# @recipe function f(pr::PianoRoll)
#     ons, offs, pitches = pr.args
#     x := map(note_to_shape, ons, offs, pitches)
#     seriestype := :shape
#     ()
# end

function pianoroll(notes::AbstractVector{N}; kwargs...) where {P,T,N<:Note{P,T}}
    Plots.plot(map(note_to_shape, notes))
end

end # module
