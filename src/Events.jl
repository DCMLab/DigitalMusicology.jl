module Events

import Base: ==, hash, show
import DigitalMusicology: onset, offset, duration, hasonset, hasoffset, hasduration

export PointEvent, IntervalEvent

abstract type Event end

## time-point events
## -----------------

struct PointEvent{T<:Number,C}
    time :: T
    content :: C
end

# Base interfaces

hash(pe::PointEvent, x::UInt) = hash(pe.time, hash(pe.content, x))

==(pe1::PointEvent{T,C}, pe2::PointEvent{T,C}) where {T,C} =
    pe1.time == te2.time && pe1.content == pe2.content

show(io::IO, pe::PointEvent) =
    write(io, string("PEv<", pe.time, ">(", pe.content, ")"))

# DM interfaces

onset(pe::PointEvent) = pe.time

hasonset(::Type{PointEvent}) = true

hasoffset(::Type{PointEvent}) = false

hasduration(::Type{PointEvent}) = false

## time-interval events
## --------------------

struct IntervalEvent{T<:Number,C}
    onset :: T
    offset :: T
    content :: C
end

# Base interfaces

hash(ie::IntervalEvent, x::UInt) =
    hash(ie.onset, hash(ie.offset, hash(ie.content, x)))

==(ie1::IntervalEvent{T,C}, ie2::IntervalEvent{T,C}) where {T,C} =
    ie1.onset == ie2.onset &&
    ie1.offset == ie2.offset &&
    ie1.content == ie2.content

show(io::IO, ie::IntervalEvent) =
    write(io, string("IEv<", ie.onset, "-", ie.offset, ">(", ie.content, ")"))

# DM interfaces

onset(ie::IntervalEvent) = ie.onset

offset(ie::IntervalEvent) = ie.offset

duration(ie::IntervalEvent) = ie.offset - ie.onset

hasonset(::Type{IntervalEvent}) = true

hasoffset(::Type{IntervalEvent}) = true

hasduration(::Type{IntervalEvent}) = true

end # module Events
