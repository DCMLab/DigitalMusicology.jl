module Meter

using DigitalMusicology
import Base: ==, hash, show, numerator, denominator
import DigitalMusicology: duration, hasonset, hasoffset, hasduration

using Primes: factor

export AbstractTimeSignature
export TimeSignature, @time_str
export metricweight, defaultmeter
export TimeSigMap, inbar, barbeatsubb

abstract type AbstractTimeSignature end

## Standard Time Signature
## =======================

"""
    TimeSignature(num, denom)

A simple time signature consisting of numerator and denomenator.
"""
struct TimeSignature <: AbstractTimeSignature
    num :: Int
    denom :: Int
end

# Base interfaces

numerator(ts::TimeSignature) = ts.num

denominator(ts::TimeSignature) = ts.denom

hash(ts::TimeSignature, x::UInt) = hash(ts.num, hash(ts.denom, x))

==(ts1::TimeSignature, ts2::TimeSignature) =
    ts1.num == ts2.num && ts1.denom == ts2.denom

show(io::IO, ts::TimeSignature) = write(io, string("(", ts.num, "/", ts.denom, ")"))

# DM interfaces

duration(ts::TimeSignature) = ts.num // ts.denom

hasduration(::Type{TimeSignature}) = true

hasonset(::Type{TimeSignature}) = false

hasoffset(::Type{TimeSignature}) = false

# extra functionality

"""
    time"num/denom"

Creates a TimeSignature object with numerator `num` and denominator `denom`.
"""
macro time_str(ts)
    m = match(r"(\d+)/(\d+)", ts)
    TimeSignature(parse(m[1]), parse(m[2]))
end

"""
    defaultmeter(timesig [, warning=true])

For a time signature with sufficiently clear meter, returns the meter of the time signature.
The meter is given as a list of group sizes in beats, i.e., only the numerator matters.
For example, 2/2 -> [1], 4/4 -> [2,2], 3/4 -> [3], 3/8 -> 3, 6/8 -> [3,3], 12/8 -> [3,3,3,3].
"""
defaultmeter(ts::TimeSignature; warning=true) =
    if ts.num == 1
        [1]
    elseif ts.num % 3 == 0
        fill(3, div(ts.num, 3))
    elseif ts.num % 2 == 0
        fill(2, div(ts.num, 2))
    elseif warning
        warn("could not guess correct meter for time signature ", ts)
        nothing
    end

    # if ts.num == 1
    #     [1]
    # elseif ts.num == 2
    #     [2]
    # elseif ts.num == 3
    #     [3]
    # elseif ts.num == 4
    #     [2,2]
    # elseif ts.num == 

## Meter
## =====

"""
    metricweight(barpos, meter, beat)

Returns the metric weight of a note starting at `barpos` from the beginning of a bar
according to a meter.
The `meter` is provided as a vector of group sizes in `beat`s.
E.g., a 4/4 meter consists of 2 groups of two quarters,
so `meter` would be `[2,2]` and `beat` would be `1/4`.
The total length of the bar should be a multiple of `beat`.
Each onset on a beat gets weight 1, the first beat of each group gets weight 2,
and the first beat of the bar gets weight 4 (except if there is only one group, then 2).
The weight of each subbeat is 1/2^p,
where p is the number of prime factors needed to express the subbeat
relative to its preceding beat and the `beat` unit.
This way, tuplet divisions can be handled properly.
"""
function metricweight(barpos::Rational{Int}, meter::Vector{Int}, beat::Rational{Int})
    if barpos == 0
        length(meter) == 1 ? 2//1 : 4//1
    elseif barpos >= sum(meter)*beat
        0//1
    elseif any(g -> barpos == beat*g, cumsum(meter))
        2//1
    elseif barpos % beat == 0
        1//1
    else
        subbeat = (barpos % beat) / beat
        1 // (2 ^ length(factor(Vector, denominator(subbeat))))
    end
end

"""
    metricweight(barpos, timesig)

Tries to guess meter and beat from `timesig`.
Otherwise identical to `metricweight(barpos, meter, beat)`.
"""
metricweight(barpos::Rational{Int}, ts::TimeSignature) =
    metricweight(barpos, defaultmeter(ts), 1//denominator(ts))

## Time Maps
## =========

const TimeSigMap{T} = TimePartition{T,TimeSignature}

"""
    inbar(t, timesigmap)

Returns the time point `t` relative to the beginning of the bar it lies in.
"""
inbar(time::T, tsm::TimeSigMap{T}) where T =
    let i = findevent(tsm, time),
        tsev = tsm[max(i,1)], # upbeats don't lie in the time map, but the first TS applies
        rel = time - onset(tsev)
        mod(rel, duration(content(tsev)))
    end

# bbsnext:
# used by barbeatsubb, looks at a time and returns bar, beat, and subbeat;
# updates its input variables barsbefore and tsindex,
# can therefore be used in a stateful context like a loop
macro bbsnext(barsbefore, tsindex, time, tsm)
    quote
        begin
            # progress to timespan
            while $(esc(time)) >= offset($(esc(tsm))[$(esc(tsindex))]) &&
                $(esc(tsindex)) < length($(esc(tsm)))
                segment = $(esc(tsm))[$(esc(tsindex))]
                $(esc(barsbefore)) += ceil(Int, duration(segment)/duration(content(segment)))
                $(esc(tsindex)) += 1
            end

            # shortcuts, for readability
            tsevent = $(esc(tsm))[$(esc(tsindex))]
            tsig = content(tsevent)
            barlen = duration(tsig)
            beatlen = 1//denominator(tsig)

            # calculate bar, beat, and subbeat
            reltime = $(esc(time)) - onset(tsevent)
            relbar = floor(Int, reltime/barlen)
            inbar = mod(reltime, barlen)
            
            bar = relbar + $(esc(barsbefore))
            beat = floor(Int, inbar / beatlen)
            subb = (inbar / beatlen) % 1
            
            (bar, beat, subb)
        end
    end
end


"""
    barbeatsubb(t, timesigmap)

Returns a triple `(bar, beat, subbeat)`
that indicates bar, beat, and subbeat of `t` in the context of `timesigmap`.
"""
function barbeatsubb(time::T, tsm::TimeSigMap{T}) where T
    bb = 1
    i = 1
    @bbsnext(bb, i, time, tsm)
end

# barbeatsubb(time::T, tsm::TimeSigMap{T}) where T =
#     barbeatsubb([time], tsm)[1]

"""
    barbeatsubb(ts::Vector, timesigmap)

Returns a `(bar, beat, subbeat)` tuple for every time point in `ts`
in the context of `timesigmap`.
`ts` must be sorted in ascending order.
"""
function barbeatsubb(times::Vector{T}, tsm::TimeSigMap{T}) where T
    barsbefore = 1
    tsindex = 1
    out = sizehint!(Tuple{Int,Int,T}[], length(times))
    
    for time in times
        push!(out, @bbsnext(barsbefore, tsindex, time, tsm))
    end

    out
end

"""
    metricweight(t, timesigmap [, meter [, beat]])

Returns the metric weight at time point `t` in the context of `timesigmap`.
Optionally, `meter`, and `beat` may be supplied as in `metricweight(barpos, meter, beat)`
to override the default values inferred from the time signature at `t`.
"""
function metricweight(time::T, tsm::TimeSigMap{T}, meter=nothing, beat=nothing) where T
    i = findevent(tsm, time)
    tsev = tsm[max(i,1)]
    tsig = content(tsev)
    barpos = mod(time - onset(tsev), duration(tsig))
    if meter == nothing
        metricweight(barpos, tsig)
    else
        if beat == nothing
            beat = 1 // denominator(tsig)
        end
        metricweight(barpos, meter, beat)
    end
end

end # module Meter
