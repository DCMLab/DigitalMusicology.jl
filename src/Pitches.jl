module Pitches

import Base: show, +, -, convert, zero, isless

export Pitch
export MidiPitch, midi, midis, @midi

"Any pitch type should be a subtype of `Pitch`."
abstract type Pitch end


# midi pitches
# ------------

"Pitches represented as chromatic integers.
60 is Middle C."
struct MidiPitch <: Pitch
    pitch :: Int
end

"Creates a `MidiPitch` from an integer."
midi(pitch::Int) = MidiPitch(pitch)

"Maps `midi()` over a collection of integers."
midis(pitches) = map(midi, pitches)

"""
    @midi expr

Replaces all `Int`s in `expr` with a call to `midi(::Int)`.
This allows the user to write integers where midi pitches are required.
Does not work when `expr` contains integers that should not be converted.
"""
macro midi(expr)
    mkmidi(x) = x
    mkmidi(e::Expr) = Expr(e.head, map(mkmidi, e.args)...)
    mkmidi(n::Int) = :(midi($n))

    return esc(mkmidi(expr))
end

## midi pitches: methods from base

show(io::IO, p::MidiPitch) = show(io, p.pitch)

convert(::Type{MidiPitch}, x::N) where {N<:Number} = midi(convert(Int, x))
convert(::Type{Pitch}, x::N) where {N<:Number} = midi(convert(Int, x))

+(p1::MidiPitch, p2::MidiPitch) = midi(p1.pitch + p2.pitch)

-(p1::MidiPitch, p2::MidiPitch) = midi(p1.pitch - p2.pitch)
-(p::MidiPitch) = midi(-p.pitch)

zero(::Type{MidiPitch}) = midi(0)
zero(::MidiPitch) = midi(0)

isless(p1::MidiPitch, p2::MidiPitch) = isless(p1.pitch, p2.pitch)

end # module
