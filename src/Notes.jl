module Notes

using ...DigitalMusicology
import Base: hash, ==, show
import ..Timed: onset, offset, duration, hasonset, hasoffset, hasduration
import ..PitchCollections: pitches

export Note, TimedNote, pitch, id

# Abstract Notes
# ==============

"""
Notes are combinations of pitch and time information.
"""
abstract type Note{I<:Interval,T} end

"""
    pitch(note)

Returns the pitch of a note
"""
function pitch end

"""
    id(obj)

Returns the ID of `obj`.
"""
function id end

## implement interfaces

pitches(notes::AbstractVector{N}) where {N<:Note} =
    map(pitch, notes)

# TimedNote
# =========

"""
A simple timed note. Pitch + onset + offset.
"""
struct TimedNote{I,T} <: Note{I,T}
    pitch :: Pitch{I}
    onset :: T
    offset :: T
    id :: Union{String,Nothing,Missing}
end
TimedNote(pitch, onset, offset) = TimedNote(pitch, onset, offset, nothing)

pitch(n::TimedNote) = n.pitch

id(n::TimedNote) = n.id

### Timed interface

onset(n::TimedNote) = n.onset

offset(n::TimedNote) = n.offset

hasonset(::Type{TimedNote}) = true
hasoffset(::Type{TimedNote}) = true
hasduration(::Type{TimedNote}) = true

### Base implementations

==(t1::TimedNote{P,T}, t2::TimedNote{P,T}) where {P,T} =
    t1.pitch == t2.pitch && t1.onset == t2.onset && t1.offset == t2.offset

hash(t::TimedNote, x::UInt) = hash(t.pitch, hash(t.onset, hash(t.offset, x)))

show(io::IO, t::TimedNote) =
    let id = isa(t.id,String) ? "#" * t.id : ""
        print(io, "Note$id<$(t.onset)-$(t.offset)>($(t.pitch))")
    end

end # module
