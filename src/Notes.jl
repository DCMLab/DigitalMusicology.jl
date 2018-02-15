module Notes

using DigitalMusicology
import Base: hash, ==, show
import DigitalMusicology.Timed: onset, offset, duration, hasonset, hasoffset, hasduration

export Note, TimedNote, pitch

# Abstract Notes
# ==============

"""
Notes are combinations of pitch and time information.
"""
abstract type Note{P<:Pitch,T} end

"""
    pitch(note)

Returns the pitch of a note
"""
function pitch end

# TimedNote
# =========

"""
A simple timed note. Pitch + onset + offset.
"""
struct TimedNote{P,T} <: Note{P,T}
    pitch :: P
    onset::T
    offset::T
end

pitch(n::TimedNote) = n.pitch

### Timed interface

onset(n::TimedNote) = n.onset

offset(n::TimedNote) = n.offset

hasonset(::Type{TimedNote}) = true
hasoffset(::Type{TimedNote}) = true
hasduration(::Type{TimedNote}) = true

### Base implementations

==(t1::TimedNote{P,T}, t2::TimedNote{P,T}) where {P,T} =
    t1.pitch == t2.pitch && t1.onset == t2.onset && t1.offset == t2.offset

hash(t::TimedNote) = hash(t.pitch, hash(t.onset, hash(t.offset, x)))

show(io::IO, t::TimedNote) =
    write(io, string("Note<", t.onset, "-", t.offset, ">(", t.pitch, ")"))

end # module
