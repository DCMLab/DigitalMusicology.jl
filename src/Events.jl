module Events

import Base: ==, hash, show, convert,
    start, done, next, length, eltype, iteratorsize, iteratoreltype,
    getindex, setindex!, endof
import DigitalMusicology: onset, offset, duration, hasonset, hasoffset, hasduration

export PointEvent, IntervalEvent, content
export TimePartition, split!, events, findevent

abstract type Event end

"""
    content(event)

Returns the event's content.
"""
function content end

## time-point events
## -----------------

"""
    PointEvent(time::T, content::C)

An event that happens at a certain point in time.
Has an onset but no offset or duration.
"""
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

content(pe::PointEvent) = pe.content

onset(pe::PointEvent) = pe.time

hasonset(::Type{PointEvent}) = true

hasoffset(::Type{PointEvent}) = false

hasduration(::Type{PointEvent}) = false

## time-interval events
## --------------------

"""
    IntervalEvent(onset::T, offset::T, content::C)

An event that spans a time interval.
Has onset, offset, and duration.
"""
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

content(ie::IntervalEvent) = ie.content

onset(ie::IntervalEvent) = ie.onset

offset(ie::IntervalEvent) = ie.offset

duration(ie::IntervalEvent) = ie.offset - ie.onset

hasonset(::Type{IntervalEvent}) = true

hasoffset(::Type{IntervalEvent}) = true

hasduration(::Type{IntervalEvent}) = true

### Time Partition
### ==============

"""
    TimePartition(breaks::Vector{T}, contents::Vector{C}

Partitions a time span into half-open intervals
[t0,t1), [t1,t2), ..., [tn-1,tn), where each interval has a content.
The default constructor takes vectors of time points `[t0...tn]`
and content `[c1...cn]`.
There must be one more time point than content items.
The whole partition has a total onset, offset, and duration.

A `TimePartition` may be iterated over (as `IntervalEvent`s)
and subintervals can be accessed by their indices.
While getting an index returns a complete `IntervalEvent`,
setting an index sets only the content of the corresponding interval.

    tp[2] -> IEv<0.5-1.0>("foo")
    tp[2] = "bar"
"""
struct TimePartition{T<:Number,C}
    breaks :: Vector{T}
    contents :: Vector{C}

    TimePartition{T,C}(bs::Vector{T}, cs::Vector{C}) where {T<:Number,C} =
        if length(bs) != length(cs) + 1
            error("mismatch between number of time spans and contents")
        elseif !issorted(bs)
            error("breaks are not sorted")
        else
            new(bs, cs)
        end
end

"""
    events(timepartition)

Returns a vector of time-interval events that correspond to the
subintervals and their content in `timepartition`.
"""
events(tp::TimePartition) =
    [IntervalEvent(breaks[i], breaks[i+1], contents[i]) for i in 1:length(contents)]

"""
    findevent(timepartition, time)

Returns the index of the interval in `timepartition` that contains the timepoint `time`.
"""
findevent(tp::TimePartition{T,C}, time::T) where {T,C} =
    searchsortedfirst(tp.breaks, time)

"""
    split!(timepartition, at, before, after)

Splits the subinterval [ti,ti+1) of `timepartition` that contains `at`
into [ti,`at`) with content `before` and [`at`,t2] with content `after`.
"""
split!(tp::TimePartition{T,C}, at::T, before::C, after::C) where{T,C} =
    let i = findevent(tp, at)
        if i > length(tp)
            push!(tp.breaks, at)
            push!(tp.contents, before)
        else
            insert!(tp.breaks, i+1, at)
            insert!(tp.contents, i+1, after)
            if i > 0
                tp.contents[i] = before
            end
        end
    end

# base interfaces

hash(tp::TimePartition, x::UInt) = hash(tp.breaks, hash(tp.contents, x))

==(tp1::TimePartition{T,C}, tp2::TimePartition{T,C}) where {T,C} =
    tp1.breaks == tp2.breaks &&
    tp1.contents == tp2.contents

show(io::IO, tp::TimePartition) = show(io, events(tp))

convert(::Type{TimePartition}, ie::IntervalEvent) =
    TimePartition([onset(ie), offset(ie)], [content(ie)])

#indices

getindex(tp::TimePartition, i) = IntervalEvent(tp.breaks[i], tp.breaks[i+1], tp.contents[i])

function setindex!(tp::TimePartition{T,C}, v::C, i) where {T,C}
    tp.contents[i] = v
end

endof(tp::TimePartition) = endof(tp.contents)

#iteration

start(tp::TimePartition) = 1

done(tp::TimePartition, i) = i > endof(tp)

next(tp::TimePartition) = tp[i], i+1

iteratorsize(::Type{TimePartition}) = Base.HasLength()

length(tp::TimePartition) = endof(tp)

iteratoreltype(::Type{TimePartition}) = Base.HasEltype()

eltype(::Type{TimePartition{T,C}}) where {T,C} = IntervalEvent{T,C}

#TODO: iterator / index interfaces

# DM interfaces

onset(tp::TimePartition) = tp.breaks[1]

offset(tp::TimePartition) = tp.breaks[end]

duration(tp::TimePartition) = tp.breaks[end] - tp.breaks[1]

hasonset(tp::TimePartition) = true

hasoffset(tp::TimePartition) = true

hasduration(tp::TimePartition) = true

end # module Events
