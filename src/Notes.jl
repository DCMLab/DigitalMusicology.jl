module Notes

using DigitalMusicology
using DataFrames
using Ratios
using Base.Iterators
import Base: hash, ==, show
import DigitalMusicology.Timed: onset, offset, duration, hasonset, hasoffset, hasduration
import DigitalMusicology.PitchCollections: pitches
import Base: iterate, IteratorSize, IteratorEltype, length, HasLength, HasEltype

export Note, TimedNote, pitch
export Itermidi, notesequence,quantize, ismonophonic

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

## implement interfaces

pitches(notes::AbstractVector{N}) where {N<:Note} =
    map(pitch, notes)

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

hash(t::TimedNote, x::UInt) = hash(t.pitch, hash(t.onset, hash(t.offset, x)))

show(io::IO, t::TimedNote) =
    write(io, string("Note<", t.onset, "-", t.offset, ">(", t.pitch, ")"))



"""
    Itermidi

Iteror over DataFrames representing midi files. The iterator returns a TimedNote
"""
struct Itermidi
    midiframe :: DataFrame
    timetype :: String
end


function iterate(iter ::Itermidi, state :: Int64 = 0)
    if state >= size(iter.midiframe,1)
        return nothing
    end
    note = TimedNote(iter.midiframe[state+1,:pitch],iter.midiframe[state+1,Symbol("onset_",iter.timetype)],iter.midiframe[state+1,Symbol("offset_",iter.timetype)])
    return (note,state +1)
end

IteratorSize(::Type{Itermidi}) = HasLength()
IteratorEltype(::Type{Itermidi}) = HasEltype()
length(iter :: Itermidi) = size(iter.midiframe,1)


"""
    notesequence(notes,n :: Int64)

return an iterator over all sequences of 'n' consecutive notes
"""
function notesequence(notes,n :: Int64)
    seq = []
    for i = 1:n
        push!(seq,drop(notes,i-1))
    end
    return map(collect,zip(seq...))
end

"""
    quantize(notes,tresh = 1//8 )

quantize the given notes on a grid which has "cells" of length 'thresh'
Caution : sometime the resulting onsets and offsets can have rounding problems (eg. 40.400000000006)
"""
function quantize(note,tresh = 1//8 )

    return TimedNote(pitch(note),round(Int64,onset(note)/tresh)*tresh,round(Int64,offset(note)/tresh)*tresh)
end
"""
    ismonophonic(notes,overlap = 0.1)

verify if the iterator of notes is monophonic with a tolerance given by ‘overlap’
"""
function ismonophonic(notes,overlap = 0.1)
    if overlap < 0
        println("WARNING : negative overlap")
        overlap *= -1
    end
    ismono = true
    i = 1
    prev = iterate(notes)
    next = (prev == nothing) ? nothing : iterate(notes,prev[2])
    while ismono && next != nothing

        if onset(next[1])- offset(prev[1]) < -overlap
            ismono = false
        end
        prev = next
        next = iterate(notes,prev[2])
    end
    return ismono
end

end # module
