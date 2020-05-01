export SpelledInterval, spelled, spelledp
export SpelledIC, sic, spc
export parsespelled, parsespelledpitch, @i_str, @p_str

import Base: +, -, *, ==

# helpers

const diachrom = Int[0, 2, 4, 5, 7, 9, 11]
const dianames = String["C","D", "E", "F", "G", "A", "B"]
const dianames_lookup = Dict(l => i-1 for (i, l) in enumerate(dianames))
# const diaints  = String["uni", "2nd", "3rd", "4th", "5th", "6th", "7th"]
const diafifths = Int[0,2,4,-1,1,3,5]
const perfectints = Set{Int}([0,3,4])
diatochrom(d) = diachrom[mod(d, 7) + 1] + 12 * fld(d, 7)
accstr(n, u, d) =
    if n > 0; repeat(u,n) elseif n < 0; repeat(d,-n) else "" end
qualpf(n, a, p, d) =
    if n > 0; repeat(a,n) elseif n < 0; repeat(d,-n) else p end
qualimpf(n, a, mj, mn, d) =
    if n > 0; repeat(a,n) elseif n < -1; repeat(d,-n-1) elseif n == -1; mn else mj end

# spelled interval
# ----------------

"""
    SpelledInterval <: Interval

Spelled intervals represented as pairs of diatonic and chromatic steps.
E.g., `SpelledInterval(4, 7)` represents a perfec 5th (4 diatonic steps, 7 semitones).
"""
struct SpelledInterval <: Interval
    d :: Int # diatonic steps
    c :: Int # chromatic steps
end

"""
    spelled(d, c)

Creates a spelled interval with `d` diatonic and `c` chromatic steps.
"""
spelled(d, c) = SpelledInterval(d,c)

"""
    spelledp(d, c)

Creates a spelled pitch with `d` diatonic and `c` chromatic steps.
"""
spelledp(d, c) = Pitch(spelled(d, c))

function Base.show(io::IO, i::SpelledInterval)
    # negative? print as -abs(i)
    if sign(i) == -1
        print(io, "-")
        print(io, abs(i))
        return
    end
    
    dia = mod(i.d, 7)
    diff = i.c - diatochrom(i.d)
    qual = if dia ∈ perfectints
        qualpf(diff, 'a', 'P', 'd')
    else
        qualimpf(diff, 'a', 'M', 'm', 'd')
    end
    
    oct = fld(i.d, 7)
    octstr = if oct >= 0; '+' * string(oct) else string(oct) end
    print(io, qual * string(dia+1) * octstr)
end

function Base.show(io::IO, p::Pitch{SpelledInterval})
    dia = p.pitch.d
    alter = p.pitch.c - diatochrom(dia)
    print(io, string(dianames[mod(dia, 7) + 1], accstr(alter, '♯', '♭'), fld(dia, 7)))
end

Base.isless(i1::SpelledInterval, i2::SpelledInterval) =
    isless(i1.d,i2.d) || (i1.d == i2.d && isless(i1.c, i2.c))

Base.isequal(i1::SpelledInterval, i2::SpelledInterval) =
    i1.d == i2.d && i1.c == i2.c

Base.hash(i::SpelledInterval, x::UInt) = hash(i.d, hash(i.c, x))

+(i1::SpelledInterval, i2::SpelledInterval) = spelled(i1.d + i2.d, i1.c + i2.c)
-(i1::SpelledInterval, i2::SpelledInterval) = spelled(i1.d - i2.d, i1.c - i2.c)
-(i::SpelledInterval) = spelled(-i.d, -i.c)
Base.zero(::Type{SpelledInterval}) = spelled(0,0)
Base.zero(::SpelledInterval) = spelled(0,0)
*(i::SpelledInterval, n::Int) = spelled(i.d*n, i.c*n)
*(n::Int,i::SpelledInterval) = spelled(i.d*n, i.c*n)

tomidi(i::SpelledInterval) = midi(i.c)
tomidi(p::Pitch{SpelledInterval}) = midip(p.interval.c + 12)  # C4 = 48 semitones above C0 = midi(60)
octave(::Type{SpelledInterval}) = spelled(7,12)
Base.sign(i::SpelledInterval) = sign(i.d)
Base.abs(i::SpelledInterval) = spelled(abs(i.d), abs(i.c))

ic(i::SpelledInterval) = sic(i.d, i.c)
embed(i::SpelledInterval) = i
intervaltype(::Type{SpelledInterval}) = SpelledInterval
intervalclasstype(::Type{SpelledInterval}) = SpelledIC

isstep(i::SpelledInterval) = abs(i.d) <=1
chromsemi(::Type{SpelledInterval}) = spelled(0,1)

# spelled interval class
# ----------------------

"""
    SpelledIC <: IntervalClass

Spelled interval class represented on the line of 5ths with `0 = C`.
E.g., `SpelledIC(3)` represents a major 6th upwards or minor 3rd downwards
(i.e., three 5ths up modulo octave).
"""
struct SpelledIC <: IntervalClass
    fifths :: Int
end

"""
    sic(n)
    sic(d, c)

Creates a spelled interval class going `n` 5ths upwards.
If one argument is prodived, it is interpreted as the number of 5th.
If two arguments are provided, they will be interpreted as diatonic and chromatic steps
and converted accordingly.
"""
sic(fs) = SpelledIC(fs)
function sic(dia, chrom)
    diff = chrom - diatochrom(dia)
    sic(diafifths[mod(dia, 7) + 1] + 7*diff) # 7 5ths = 1 chromatic semitone
end

"""
    spc(n)
    spc(d, c)

Creates a spelled pitch class.
In analogy to `sic`, this function takes either a number of 5ths
or a number of diatonic and chromatic steps.
"""
spc(fs) = Pitch(sic(fs))
spc(dia, chrom) = Pitch(sic(dia, chrom))

function Base.show(io::IO, ic::SpelledIC)
    i = embed(ic)
    diff = i.c - diatochrom(i.d)
    qual = if i.d ∈ perfectints
        qualpf(diff, 'a', 'P', 'd')
    else
        qualimpf(diff, 'a', 'M', 'm', 'd')
    end
    
    print(io, qual * string(i.d+1))
end

function Base.show(io::IO, p::Pitch{SpelledIC})
    i = embed(p.pitch)
    alter = i.c - diatochrom(i.d)
    print(io, dianames[mod(i.d,7) + 1] * accstr(alter, '♯', '♭'))
end

Base.isless(i1::SpelledIC, i2::SpelledIC) = isless(i1.fifths,i2.fifths)
Base.isequal(i1::SpelledIC, i2::SpelledIC) = isequal(i1.fifths,i2.fifths)
Base.hash(i::SpelledIC, x::UInt) = hash(i.fifths, x)

+(i1::SpelledIC, i2::SpelledIC) = sic(i1.fifths + i2.fifths)
-(i1::SpelledIC, i2::SpelledIC) = sic(i1.fifths - i2.fifths)
-(i::SpelledIC) = sic(-i.fifths)
Base.zero(::Type{SpelledIC}) = sic(0)
Base.zero(::SpelledIC) = sic(0)
*(i::SpelledIC, n::Int) = sic(i.fifths * n)
*(n::Int,i::SpelledIC) = sic(i.fifths * n)

tomidi(i::SpelledIC) = midic(i.fifths * 7)
tomidi(p::Pitch{SpelledIC}) = midipc(p.interval.fifths * 7)
octave(::Type{SpelledIC}) = sic(0)
Base.sign(i::SpelledIC) = if embed(i).d == 0; 0 elseif embed(i).d > 3; -1 else 1 end
Base.abs(i::SpelledIC) = i

ic(i::SpelledIC) = i
function embed(i::SpelledIC)
    dia = i.fifths * 4
    chrom = i.fifths * 7
    spelled(mod(dia, 7), chrom - (12 * fld(dia, 7)))
end
intervaltype(::Type{SpelledIC}) = SpelledInterval
intervalclasstype(::Type{SpelledIC}) = SpelledIC

isstep(i::SpelledIC) = abs(embed(i)).d <= 1
chromsemi(::Type{SpelledIC}) = sic(7)

# parsing

const rgsic = r"^(-?)(a+|d+|[MPm])([1-7])$"
const rgspelled = r"^(-?)(a+|d+|[MPm])([1-7])(\+|-)(\d+)$"

function matchinterval(modifier, num)
    dia = parse(Int, num) - 1
    defchrom = diachrom[dia+1]
    perfect = dia ∈ perfectints
    chrom = if modifier == "M" && !perfect
        defchrom
    elseif modifier == "m" && !perfect
        defchrom-1
    elseif lowercase(modifier) == "p" && perfect
        defchrom
    elseif occursin(r"^a+$", modifier)
        defchrom + length(modifier)
    elseif occursin(r"^d+$", modifier)
        defchrom - length(modifier) - (perfect ? 0 : 1)
    else
        error("cannot parse interval \"$modifier$num\"")
    end
    spelled(dia, chrom)
end

# TODO: write tests
function parsespelled(str)
    m = match(rgsic, str)
    if m != nothing
        int = ic(matchinterval(m[2], m[3]))
    else
        m = match(rgspelled, str)
        if m != nothing
            int = matchinterval(m[2], m[3])
            octs = parse(Int, m[4]*m[5])
            int += octave(SpelledInterval, octs)
        else
            error("cannot parse interval \"$str\"")
        end
    end

    # invert if necessary
    if m[1] == "-"
        -int
    else
        int
    end
end

macro i_str(str)
    parsespelled(str)
end

const rgspelledpc = r"^([a-g])(♭+|♯+|b+|#+)?$"i
const rgspelledp = r"^([a-g])(♭+|♯+|b+|#+)?(-?\d+)$"i

function matchpitch(letter, accs)
    letter = uppercase(letter)
    if haskey(dianames_lookup, letter)
        dia = dianames_lookup[letter]
    else
        error("cannot parse pitch letter \"$letter\"")
    end
    
    defchrom = diachrom[dia+1]
    chrom = if accs == nothing || accs == ""
        defchrom
    elseif occursin(r"^♭+|b+$"i, accs)
        defchrom - length(accs)
    elseif occursin(r"^♯+|#+$"i, accs)
        defchrom + length(accs)
    else
        error("cannot parse accidentals \"$accs\"")
    end

    spelledp(dia, chrom)
end

function parsespelledpitch(str)
    m = match(rgspelledpc, str)
    if m != nothing
        pc(matchpitch(m[1], m[2]))
    else
        m = match(rgspelledp, str)
        if m != nothing
            octs = parse(Int, m[3])
            matchpitch(m[1], m[2]) + octave(SpelledInterval, octs)
        else
            error("cannot parse pitch \"$str\"")
        end
    end
end

macro p_str(str)
    parsespelledpitch(str)
end
