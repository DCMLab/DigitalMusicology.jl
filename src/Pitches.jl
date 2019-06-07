module Intervals

import Base: show, +, -, *, convert, zero, isless, isequal

export Interval, IntervalClass, Pitch
export tomidi, octave, ic, isstep, chromsemi, embed, pc
export intervaltype, intervalclasstype


# Pitch: basic Types and Interfaces
# =================================

"""
   abstract type Interval end 

Any interval type should be a subtype of `Interval`.
Intervals should implement the following operations as far as possible:
- `ic`
- `tomidi`
- `octave(T)`
- `isstep`
- `chromsemi(T)`
- `intervalclasstype(T)`
- `Base.+`
- `Base.-` (negation and substraction)
- `Base.*` (with integers, both sides)
- `Base.zero(T)`
- `Base.sign`
Where `(T)` marks operations on the type itself.
"""
abstract type Interval end

"""
    abstract type IntervalClass <: Interval end

Any interval class type should be a subtype of `IntervalClass`.
In addition to the methods on intervals, interval classes should implement:
- `embed`
- `intervaltype(T)`
`intervalclasstype(T)` and `ic` should be identities.
"""
abstract type IntervalClass <: Interval end

# interfaces
# ----------

"""
    tomidi(p)

Returns a MidiInterval that corresponds to or approximates `p`.
"""
function tomidi end

"""
    octave(T, [n=1])

Returns the interval corresponding to an octave for interval type `T`.
For interval classes, this should return `zero(T)`
(a default method is provided).

If `n` is specified, the octave is multiplied by `n` first.
This is equivalent to `octave(T) * n`.

For convenience, a fallback for `octave(p::T, [n])` is provided.
Only `octave(T)` needs to be implemented.
"""
function octave end
octave(T::Type{PC}) where {PC<:IntervalClass} = zero(T)
octave(T, n::Int) = octave(T) * n
octave(p::Interval) = octave(typeof(p))

"""
    ic(i)

Returns the interval class of an interval, removing the octave
"""
function ic end

"""
    embed(ic, [oct=0])

Converts an interval class to an interval in the canonical octave,
adding `oct` octaves, if supplied.
Also works for pitches.
"""
function embed end
embed(ic, oct) = embed(pc) + octave(intervaltype(pc), oct)

"""
    intervaltype(IC::Type)

Returns for an interval class type `IC` the corresponding interval type.
For convenience, `intervaltype(ic::IC)` is also provided.
"""
function intervaltype end
intervaltype(::Any) = nothing
intervaltype(::IC) where {IC<:IntervalClass} = intervaltype(IC)

"""
    intervalclasstype(I::Type)

Returns for an interval type `I` the corresponding interval class type.
For convenience, `intervalclasstype(p::P)` is also provided.
"""
function intervalclasstype end
intervalclasstype(::Any) = nothing
intervalclasstype(::I) where {I<:Interval} = intervalclasstype(I)

"""
    isstep(p)

For diatonic intervals, indicates whether `p` is a step.
"""
function isstep end

"""
    chromsemi(I::Type)

Returns a chromatic semitone of type `I`.
"""
function chromsemi end

# pitches
# =======

"""
    Pitch{I}

Represents a pitch for the interval type `I`.
The interval is interpreted as an absolute pitch
by assuming a reference pitch.
The reference pitch is type dependent and known from context.
"""
struct Pitch{I<:Interval}
    pitch :: I
end

topitch(i::I) where {I<:Interval} = Pitch(i)

tointerval(p::Pitch{I}) where {I<:Interval} = p.pitch

+(p::Pitch{I}, i::I) where {I<:Interval} = Pitch(p.pitch + i)
+(i::I, p::Pitch{I}) where {I<:Interval} = Pitch(p.pitch + i)
-(p::Pitch{I}, i::I) where {I<:Interval} = Pitch(p.pitch - i)
pc(p::Pitch{I}) where {I<:Interval} = Pitch(ic(p.pitch))
embed(p::Pitch{I}, octs::Int) where {I<:Interval} = Pitch(embed(p.pitch, octs))

# specific interval types
# =======================

include("pitches/midi.jl")
include("pitches/spelled.jl")

end # module
