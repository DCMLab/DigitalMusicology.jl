module Pitches

import Base: show, +, -, convert, zero, isless

export Pitch
export MidiPitch, midi, midis

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

midis(pitches) = map(midi, pitches)

## midi pitches: methods from base

show(io::IO, p::MidiPitch) = show(io, p.pitch)

convert(::Type{MidiPitch}, x::N) where {N<:Number} = midi(convert(Int, x))

+(p1::MidiPitch, p2::MidiPitch) = midi(p1.pitch + p2.pitch)

-(p1::MidiPitch, p2::MidiPitch) = midi(p1.pitch - p2.pitch)

zero(::Type{MidiPitch}) = midi(0)
zero(::MidiPitch) = midi(0)

isless(p1::MidiPitch, p2::MidiPitch) = isless(p1.pitch, p2.pitch)

end # module
