module Pitches

import Base: show, +, -, convert, zero, isless

export Pitch, PitchClass
export MidiPitch, midi, midis, @midi


# Pitch: basic Types and Interfaces
# =================================

"""
   abstract type Pitch end 

Any pitch type should be a subtype of `Pitch`.
Pitches generally encode *intervals*
(which allows operations like addition and scalar multiplication)
but can be interpreted as absolute pitches relative to an origin.
"""
abstract type Pitch end

"""
    abstract type PitchClass <: Pitch end

Any pitch class type should be a subtype of `PitchClass`.
Every PitchClass is also a Pitch.
Separate pitch class types allow implementing operations
separately for pitch classes.
"""
abstract type PitchClass <: Pitch end

# Pitch Traits:
# additive group:
#   +(p,p), -(_,_), -(_), zero
# module
#   *(p,Int), *(Int,p)
# pitch
#   tomidi(p), tofreq(p)?, octave(P,n), sign(p)
# pitch class (and corresponding pitch)
#   pc(p)::pc, embed(pc)::p, pitchtype(PC), pitchclasstype(P)
# diatonic
#   isstep(p)
# optional
#   isless(p)

# interfaces
# ----------

"""
    tomidi(p)

Returns a MidiPitch that corresponds to or approximates `p`.
"""
function tomidi end

"""
    octave(T, [n=1])

Returns the interval corresponding to an octave for pitch type `T`.
For pitch classes, this should return `zero(T)`
(a default method is provided).

If `n` is specified, the octave is multiplied by `n` first.
This is equivalent to `octave(T) * n`.

For convenience, a fallback for `octave(p::T, [n])` is provided.
Only `octave(T)` needs to be implemented.
"""
function octave end
octave(T::Type{PC}) where {P<:PitchClass} = zero(T)
octave(T, n::Int) = octave(T) * n
octave(p::Pitch) = octave(typeof(p))

"""
    pc(p)

Returns the pitch class of a pitch, removing the octave
"""
function pc end

"""
    embed(pc, [oct=0])

Converts a pitch class to a pitch in the canonical octave,
or transposed by `oct` octaves, if supplied.
"""
function embed end
embed(pc, oct) = embed(pc) + octave(pitchtype(pc), oct)

"""
    pitchtype(PC::Type)

Returns for a pitch class type `PC` the corresponding pitch type.
For convenience, `pitchtype(pc::PC)` is also provided.
"""
function pitchtype end
pitchtype(::Any) = nothing
pitchtype(pc::PC) where {PC<:PitchClass} = pitchtype(P)

"""
    pitchclasstype(P::Type)

Returns for a pitch type `P` the corresponding pitch class type.
For convenience, `pitchclasstype(p::P)` is also provided.
"""
function pitchclasstype end
pitchclasstype(::Any) = nothing
pitchclasstype(p::P) where {P<:Pitch} = pitchclasstype(P)

"""
    isstep(p)

For diatonic pitches, indicates whether `p` is a step.
"""
function isstep end

# specific pitch types
# ====================

# midi pitches and classes
# ------------------------

"""
    MidiPitch <: Pitch

Pitches represented as chromatic integers.
`60` is Middle C.
"""
struct MidiPitch <: Pitch
    pitch :: Int
end

"""
    MidiPitchClass <: PitchClass

Pitch classes represented as cromatic integers in Z_12, where `0` is C.
"""
struct MidiPitchClass <: PitchClass
    pc :: Int
    MidiPitchClass(pc) = new(mod(pc,12))
end

"""
    midi(pitch)

Creates a `MidiPitch` from an integer.
"""
midi(pitch::Int) = MidiPitch(pitch)

"""
    midic(pitch)

Creates a MidiPitchClass from an integer
"""
midic(pitch::Int) = MidiPitchClass(pitch)

"""
    midis(pitches).

Maps `midi()` over a collection of integers.
"""
midis(pitches) = map(midi, pitches)

"""
    midics(pitches).

Maps `midic()` over a collection of integers.
"""
midis(pitches) = map(midic, pitches)

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

"""
    @midic expr

Replaces all `Int`s in `expr` with a call to `midi(::Int)`.
This allows the user to write integers where midi pitches are required.
Does not work when `expr` contains integers that should not be converted
or pitches that are not written as literal integers.
"""
macro midic(expr)
    mkmidi(x) = x
    mkmidi(e::Expr) = Expr(e.head, map(mkmidi, e.args)...)
    mkmidi(n::Int) = :(midic($n))

    return esc(mkmidi(expr))
end

show(io::IO, p::MidiPitch) = show(io, p.pitch)
show(io::IO, p::MidiPitchClass) = show(io, p.pc)

convert(::Type{MidiPitch}, x::N) where {N<:Number} = midi(convert(Int, x))
convert(::Type{Pitch}, x::N) where {N<:Number} = midi(convert(Int, x))
convert(::Type{Int}, p::MidiPitch) = p.pitch
convert(::Type{N}, p::MidiPitch) where {N<:Number} = convert(N, p.pitch)

convert(::Type{MidiPitchClass}, x::N) where {N<:Number} = midic(convert(Int, x))
convert(::Type{PitchClass}, x::N) where {N<:Number} = midic(convert(Int, x))
convert(::Type{Int}, p::MidiPitchClass) = p.pc
convert(::Type{N}, p::MidiPitchClass) where {N<:Number} = convert(N, p.pc)

## midi pitch: interfaces

Base.+(p1::MidiPitch, p2::MidiPitch) = midi(p1.pitch + p2.pitch)
Base.-(p1::MidiPitch, p2::MidiPitch) = midi(p1.pitch - p2.pitch)
Base.-(p::MidiPitch) = midi(-p.pitch)
Base.zero(::Type{MidiPitch}) = midi(0)
Base.zero(::MidiPitch) = midi(0)

Base.*(p::MidiPitch, n::Int) = midi(p.pitch*n)
Base.*(n::Int, p::MidiPitch) = midi(p.pitch*n)

tomidi(p::MidiPitch) = p
octave(::Type{MidiPitch}) = midi(12)
Base.sign(p::MidiPitch) = sign(p.pitch)

pc(p::MidiPitch) = midic(p.pitch)
embed(p::MidiPitch) = p
pitchtype(::Type{MidiPitch}) = MidiPitch
pitchclasstype(::Type{MidiPitch}) = MidiPitchClass

isstep(p::MidiPitch) = abs(p) <= 2
Base.isless(p1::MidiPitch, p2::MidiPitch) = isless(p1.pitch, p2.pitch)

## midi pitch class: interfaces

Base.+(p1::MidiPitchClass, p2::MidiPitchClass) = midic(p1.pc + p2.pc)
Base.-(p1::MidiPitchClass, p2::MidiPitchClass) = midic(p1.pc - p2.pc)
Base.-(p::MidiPitchClass) = midic(-p.pc)
Base.zero(::Type{MidiPitchClass}) = midic(0)
Base.zero(::MidiPitchClass) = midic(0)

Base.*(p::MidiPitchClass, n::Int) = midic(p.pc*n)
Base.*(n::Int, p::MidiPitchClass) = midic(p.pc*n)

tomidi(p::MidiPitchClass) = p
octave(::Type{MidiPitchClass}) = midic(0)
Base.sign(p::MidiPitchClass) = p.pc == 0 ? 0 : -sign(p.pc-6)

pc(p::MidiPitchClass) = p
embed(p::MidiPitchClass) = midi(p.pc)
pitchtype(::Type{MidiPitchClass}) = MidiPitch
pitchclasstype(::Type{MidiPitch}) = MidiPitchClass

isstep(p::MidiPitchClass) = p <= 2 || p >= 10
Base.isless(p1::MidiPitchClass, p2::MidiPitchClass) = isless(p1.pc, p2.pc)

end # module
