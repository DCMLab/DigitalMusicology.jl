# midi intervals and classes
# ==========================

export MidiInterval, midi, midis, @midi, midip, midips, @midip
export MidiIC, midic, midics, @midic, midipc, midipcs, @midipc

"""
    MidiInterval <: Interval

Intervals represented as chromatic integers.
`60` is Middle C.
"""
struct MidiInterval <: Interval
    interval :: Int
end

"""
    MidiIC <: IntervalClass

Interval classes represented as cromatic integers in Z_12, where `0` is C.
"""
struct MidiIC <: IntervalClass
    ic :: Int
    MidiIC(ic) = new(mod(ic,12))
end

"""
    midi(interval)

Creates a `MidiInterval` from an integer.
"""
midi(interval::Int) = MidiInterval(interval)

"""
    midip(n)

Creates a midi pitch (`Pitch{MidiInterval}`) from an integer.
"""
midip(n::Int) = Pitch(midi(n))

"""
    midic(interval)

Creates a `MidiIC` from an integer.
"""
midic(interval::Int) = MidiIC(interval)

"""
    midipc(n)

Creates a midi pitch class (`Pitch{MidiIC}`) from an integer.
"""
midipc(n::Int) = pitch(midic(n))


"""
    midis(intervals).

Maps `midi()` over a collection of integers.
"""
midis(intervals) = map(midi, intervals)

"""
    midips(ns).

Maps `midip()` over a collection of integers.
"""
midips(ns) = map(midip, ns)


"""
    midics(intervals).

Maps `midic()` over a collection of integers.
"""
midics(intervals) = map(midic, intervals)

"""
    midipcs(ns).

Maps `midipc()` over a collection of integers.
"""
midipcs(ns) = map(midipc, ns)


"""
    @midi expr

Replaces all `Int`s in `expr` with a call to `midi(::Int)`.
This allows the user to write integers where midi intervals are required.
Does not work when `expr` contains integers that should not be converted
or intervals that are not written as literal integers.
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
This allows the user to write integers where midi intervals are required.
Does not work when `expr` contains integers that should not be converted
or intervals that are not written as literal integers.
"""
macro midic(expr)
    mkmidi(x) = x
    mkmidi(e::Expr) = Expr(e.head, map(mkmidi, e.args)...)
    mkmidi(n::Int) = :(midic($n))

    return esc(mkmidi(expr))
end

"""
    @midip expr

Replaces all `Int`s in `expr` with a call to `midip(::Int)`.
This allows the user to write integers where midi intervals are required.
Does not work when `expr` contains integers that should not be converted
or intervals that are not written as literal integers.
"""
macro midip(expr)
    mkmidi(x) = x
    mkmidi(e::Expr) = Expr(e.head, map(mkmidi, e.args)...)
    mkmidi(n::Int) = :(midip($n))

    return esc(mkmidi(expr))
end

"""
    @midipc expr

Replaces all `Int`s in `expr` with a call to `midipc(::Int)`.
This allows the user to write integers where midi intervals are required.
Does not work when `expr` contains integers that should not be converted
or intervals that are not written as literal integers.
"""
macro midipc(expr)
    mkmidi(x) = x
    mkmidi(e::Expr) = Expr(e.head, map(mkmidi, e.args)...)
    mkmidi(n::Int) = :(midipc($n))

    return esc(mkmidi(expr))
end


show(io::IO, p::MidiInterval) = print(io, string("i", p.interval))
show(io::IO, p::MidiIC) = print(io, string("ic", p.ic))
show(io::IO, p::Pitch{MidiInterval}) = print(io, string("p", p.pitch.interval))
show(io::IO, p::Pitch{MidiIC}) = print(io, string("pc", p.pitch.ic))

Base.isless(p1::MidiInterval, p2::MidiInterval) = isless(p1.interval, p2.interval)
Base.isless(p1::MidiIC, p2::MidiIC) = isless(p1.ic, p2.ic)

Base.isequal(p1::MidiInterval, p2::MidiInterval) = p1.interval == p2.interval
Base.isequal(p1::MidiIC, p2::MidiIC) = p1.ic == p2.ic

Base.hash(p::MidiInterval, x::UInt) = hash(p.interval, x)
Base.hash(p::MidiIC, x::UInt) = hash(p.ic, x)

Base.Int64(p::MidiInterval) = p.interval
convert(::Type{MidiInterval}, x::N) where {N<:Number} = midi(convert(Int, x))
convert(::Type{Interval}, x::N) where {N<:Number} = midi(convert(Int, x))
convert(::Type{Int}, p::MidiInterval) = p.interval
convert(::Type{N}, p::MidiInterval) where {N<:Number} = convert(N, p.interval)

convert(::Type{MidiIC}, x::N) where {N<:Number} = midic(convert(Int, x))
convert(::Type{IntervalClass}, x::N) where {N<:Number} = midic(convert(Int, x))
convert(::Type{Int}, p::MidiIC) = p.ic
convert(::Type{N}, p::MidiIC) where {N<:Number} = convert(N, p.ic)

## midi interval: interfaces

+(p1::MidiInterval, p2::MidiInterval) = midi(p1.interval + p2.interval)
-(p1::MidiInterval, p2::MidiInterval) = midi(p1.interval - p2.interval)
-(p::MidiInterval) = midi(-p.interval)
zero(::Type{MidiInterval}) = midi(0)
zero(::MidiInterval) = midi(0)

*(p::MidiInterval, n::Int) = midi(p.interval*n)
*(n::Int, p::MidiInterval) = midi(p.interval*n)

tomidi(p::MidiInterval) = p
octave(::Type{MidiInterval}) = midi(12)
Base.sign(p::MidiInterval) = sign(p.interval)
Base.abs(p::MidiInterval) = midi(abs(p.interval))

ic(p::MidiInterval) = midic(p.interval)
embed(p::MidiInterval) = p
intervaltype(::Type{MidiInterval}) = MidiInterval
intervalclasstype(::Type{MidiInterval}) = MidiIC

isstep(p::MidiInterval) = abs(p) <= 2
chromsemi(::Type{MidiInterval}) = midi(1)

## midi interval class: interfaces

+(p1::MidiIC, p2::MidiIC) = midic(p1.ic + p2.ic)
-(p1::MidiIC, p2::MidiIC) = midic(p1.ic - p2.ic)
-(p::MidiIC) = midic(-p.ic)
zero(::Type{MidiIC}) = midic(0)
zero(::MidiIC) = midic(0)

*(p::MidiIC, n::Int) = midic(p.ic*n)
*(n::Int, p::MidiIC) = midic(p.ic*n)

tomidi(p::MidiIC) = p
octave(::Type{MidiIC}) = midic(0)
Base.sign(p::MidiIC) = p.ic == 0 ? 0 : -sign(p.ic-6)
Base.abs(p::MidiIC) = midic(abs(p.interval))

ic(p::MidiIC) = p
embed(p::MidiIC) = midi(p.ic)
intervaltype(::Type{MidiIC}) = MidiInterval
intervalclasstype(::Type{MidiIC}) = MidiIC

isstep(p::MidiIC) = p <= 2 || p >= 10
chromsemi(::Type{MidiIC}) = midic(1)
