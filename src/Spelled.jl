module Spelled

import Base: show, +, -, *, zero
using Setfield

using DigitalMusicology.ModInts

export Acc, flat, sharp
export diatonic, chromatic
export SpelledInterval, @i_str
export SpelledPitch, @p_str
export SpelledIC, @ic_str
export SpelledPC, @pc_str
export Mode, Major, Minor, ismajor, ics
export SpelledKey, root, mode, pcs, @key_str
export ScaleDegree, key, modulate, @sd_str

####################
### Accidentials ###
####################

"""
    Acc(integer)

represents musical accidential, can be applied to spelled objects
- flats <-> integer
- sharps <-> integer
- natural <-> iszero(integer)
"""
struct Acc
    int :: Int
end

Int(a::Acc) = a.int

function Acc(str::AbstractString)
    sharps = flats = 0
    foreach(str) do a
        if a == '#'
            sharps += 1
        elseif a == 'b'
            flats  += 1
        else
            error("$str is not an accidential")
        end
    end
    Acc(sharps - flats)
end

function show(io::IO, a::Acc)
    acc_char = a.int < 0 ? "b" : "#"
    print(io, acc_char ^ abs(a.int))
end

(a::Acc)(k::Union{Int,ModInt}) = k + a.int

+(a::Acc, b::Acc) = Acc(a.int + b.int)
+(a::Acc, b::Int) = Acc(a.int + b)
+(a::Int, b::Acc) = Acc(a + b.int)

-(a::Acc, b::Acc) = Acc(a.int - b.int)
-(a::Acc)         = Acc(-a.int)

*(a::Acc, b::Int) = Acc(a.int * b)
*(a::Int, b::Acc) = Acc(a * b.int)

zero(::Type{Acc}) = Acc(0)

"sharp = Acc(1)"
const sharp = Acc(1)

"flat  = Acc(-1)"
const flat  = Acc(-1)

#########################
### Altered intervals ###
#########################

# private helper type for input / output

struct AlteredInterval
    diatonic :: Int
    acc      :: Acc
end

function show(io::IO, i::AlteredInterval)
    i.diatonic + 1 < 0 && print(io, '-')
    print(io, i.acc, abs(i.diatonic) + 1)
end

AlteredInterval(diatonic, acc::Int) = AlteredInterval(diatonic, Acc(acc))

function AlteredInterval(str::AbstractString)
    m        = match(r"(?P<sign>-?)(?P<accidential>[#b]*)(?P<digits>[1-9][0-9]*)", str)
    sign     = isempty(m[:sign]) ? 1 : -1
    diatonic = sign * (parse(Int, m[:digits]) - 1)
    AlteredInterval(diatonic, Acc(m[:accidential]))
end

################################################
### particular functions for spelled objects ###
################################################

"""
    diatonic(spelled)

diatonic size of the spelled object
"""
function diatonic end

"""
    chromatic(spelled)

chromatic size of the spelled object
"""
function chromatic end

#########################
### Spelled intervals ###
#########################

struct SpelledInterval
    fifths  :: Int
    octaves :: Int
end

SpelledInterval(str::AbstractString) = SpelledInterval(AlteredInterval(str))

show(io::IO, i::SpelledInterval) = print(io, AlteredInterval(i))

augmented_primes(i::SpelledInterval) = -1 * i.fifths -  2 * i.octaves
major_seconds(i::SpelledInterval)    =  4 * i.fifths +  7 * i.octaves
chromatic(i::SpelledInterval)        =  7 * i.fifths + 12 * i.octaves
diatonic(i::SpelledInterval)         = major_seconds(i)

function (a::Acc)(i::SpelledInterval)
    fifths  = i.fifths  + 7 * a.int
    octaves = i.octaves - 4 * a.int
    SpelledInterval(fifths, octaves)
end

function Acc(i::SpelledInterval)
    # calculations on the line of fifths
    f = i.fifths + 1
    f < 0 ? Acc(div(f-6, 7)) : Acc(div(f, 7))
end

AlteredInterval(i::SpelledInterval) = AlteredInterval(diatonic(i), Acc(i))

function SpelledInterval(i::AlteredInterval)
    fifths = 7 * Int(i.acc) + mod((2 * i.diatonic) + 1, 7) - 1
    augmented_primes, r1 = divrem(fifths - 2 * i.diatonic, 7)
    octaves, r2 = divrem(-augmented_primes - fifths, 2)
    @assert r1 == 0 == r2
    SpelledInterval(fifths, octaves)
end

macro i_str(str)
    i = SpelledInterval(str)
    :($i)
end

+(i::SpelledInterval, j::SpelledInterval) = SpelledInterval(i.fifths + j.fifths, i.octaves + j.octaves)
-(i::SpelledInterval, j::SpelledInterval) = SpelledInterval(i.fifths - j.fifths, i.octaves - j.octaves)
-(i::SpelledInterval) = SpelledInterval(-i.fifths, -i.octaves)
zero(::SpelledInterval) = SpelledInterval(0, 0)

#######################
### Spelled Pitches ###
#######################

struct SpelledPitch
    i :: SpelledInterval
end

const natural_tones = split("C D E F G A B")

function SpelledPitch(str::AbstractString)
    m       = match(r"(?P<letter>[A-G])(?P<accidential>[#b]*)(?P<octave>-?[0-9]*)", str)
    octaves = isempty(m[:octave]) ? 0 : parse(Int, m[:octave])
    diatonic = findfirst(isequal(m[:letter]), natural_tones) - 1 + 7*octaves
    i       = SpelledInterval(AlteredInterval(diatonic, Acc(m[:accidential])))
    SpelledPitch(i)
end

function show(io::IO, p::SpelledPitch)
    ai = AlteredInterval(p.i)
    octave, diatonic = divrem(ai.diatonic, 7)
    print(io, natural_tones[diatonic+1], ai.acc, octave)
end

macro p_str(str)
    p = SpelledPitch(str)
    :($p)
end

for f in [:diatonic, :chromatic, :Acc]
    @eval $f(p::SpelledPitch) = $f(p.i)
end

(a::Acc)(p::SpelledPitch) = SpelledPitch(a(p.i))

+(p::SpelledPitch, i::SpelledInterval) = SpelledPitch(p.i + i)
-(p::SpelledPitch, i::SpelledInterval) = SpelledPitch(p.i - i)
-(p::SpelledPitch, q::SpelledPitch) = p.i - q.i

################################
### Spelled interval classes ###
################################

struct SpelledIC
    fifths :: Int
end

SpelledInterval(ic::SpelledIC) = SpelledInterval(ic.fifths, (Int(diatonic(ic)) - 4 * ic.fifths) / 7)
SpelledIC(i::SpelledInterval)  = SpelledIC(i.fifths)
SpelledIC(str::AbstractString) = SpelledIC(SpelledInterval(str))
show(io::IO, ic::SpelledIC)    = print(io, SpelledInterval(ic))

macro ic_str(str)
    ic = SpelledIC(str)
    :($ic)
end

(a::Acc)(ic::SpelledIC) = SpelledIC((7a)(ic.fifths))

diatonic(ic::SpelledIC)  = ModInt{7}(4 * ic.fifths)
chromatic(ic::SpelledIC) = ModInt{12}(chromatic(SpelledInterval(ic)))

function Acc(ic::SpelledIC)
    f = ic.fifths + 1 # shift one fifth (C to F etc.)
    f < 0 ? Acc(div(f-6, 7)) : Acc(div(f, 7))
end

+(ic1::SpelledIC, ic2::SpelledIC) = SpelledIC(ic1.fifths + ic2.fifths)
-(ic1::SpelledIC, ic2::SpelledIC) = SpelledIC(ic1.fifths - ic2.fifths)
-(ic::SpelledIC) = SpelledIC(-ic.fifths)
zero(::Type{SpelledIC}) = SpelledIC(0)

#############################
### Spelled pitch classes ###
#############################

struct SpelledPC
    ic :: SpelledIC
end

SpelledPC(str::AbstractString) = SpelledPC(SpelledPitch(str))
SpelledPC(p::SpelledPitch) = SpelledPC(SpelledIC(p.i))
SpelledPitch(pc::SpelledPC) = SpelledPitch(SpelledInterval(pc.ic))

function show(io::IO, pc::SpelledPC)
    m = match(r"([A-G][b#]*)-?[0-9]*", string(SpelledPitch(pc)))
    print(io, m[1])
end

macro pc_str(str)
    pc = SpelledPC(str)
    :($pc)
end

for f in [:diatonic, :chromatic, :Acc]
    @eval $f(pc::SpelledPC) = $f(pc.ic)
end

(a::Acc)(pc::SpelledPC) = SpelledPC(a(pc.ic))

+(pc::SpelledPC, ic::SpelledIC) = SpelledPC(pc.ic + ic)
-(pc::SpelledPC, ic::SpelledIC) = SpelledPC(pc.ic - ic)
-(pc1::SpelledPC, pc2::SpelledPC) = pc1.ic - pc2.ic

#############
### Modes ###
#############

@enum Mode Major Minor

const major_ics = map(SpelledIC, split("1 2 3 4 5 6 7"))
const minor_ics = map(SpelledIC, split("1 2 b3 4 5 b6 b7"))

ismajor(m::Mode) = m === Major
ics(m::Mode) = ismajor(m) ? major_ics : minor_ics

####################
### Spelled Keys ###
####################

"""
    SpelledKey(root, mode)

key with spelled root and mode either major or minor
"""
struct SpelledKey
    root :: SpelledPC
    mode :: Mode
end

function SpelledKey(str::AbstractString)
    m    = match(r"(?P<letter>[A-Ga-g])(?P<accidential>[#b]*)", str)
    mode = all(isuppercase, m[:letter]) ? Major : Minor
    root = SpelledPC(string(map(uppercase, m[:letter]), m[:accidential]))
    SpelledKey(root, mode)
end

macro key_str(str)
    k = SpelledKey(str)
    :($k)
end

root(k::SpelledKey) = k.root
mode(k::SpelledKey) = k.mode
ismajor(k::SpelledKey) = ismajor(mode(k))

show(io::IO, k::SpelledKey) = print(io, map(ismajor(k) ? identity : lowercase, string(root(k))))

ics(k::SpelledKey) = ics(mode(k))
pcs(k::SpelledKey) = [root(k) + ic for ic in ics(k)]

+(k::SpelledKey, ic::SpelledIC) = @set k.root += ic
-(k::SpelledKey, ic::SpelledIC) = @set k.root -= ic

#####################
### Scale degrees ###
#####################

"""
    ScaleDegree(diatonic, accidential, key)

construct a scale degree in a spelled key
"""
struct ScaleDegree
    diatonic :: ModInt{7}
    acc      :: Acc
    key      :: SpelledKey
end

diatonic(sd::ScaleDegree) = sd.diatonic
chromatic(sd::ScaleDegree) = chromatic(SpelledPC(sd))
Acc(sd::ScaleDegree) = sd.acc
key(sd::ScaleDegree) = sd.key

(a::Acc)(sd::ScaleDegree) = @set sd.acc += a

const numeral_names = split("I II III IV V VI VII")
show(io::IO, sd::ScaleDegree) = print(io, Acc(sd), numeral_names[diatonic(sd)], "_{", sd.key, "}")

function ScaleDegree(str::AbstractString, k::SpelledKey)
    m = match(r"(?P<accidential>[#b]*)(?P<numeral>[IV]+)", str)
    diatonic = findfirst(isequal(m[:numeral]), numeral_names) - 1
    ScaleDegree(diatonic, Acc(m[:accidential]), k)
end

function ScaleDegree(str::AbstractString)
    m = match(r"(?P<alterednumeral>[#b]*[IV]+)_{(?P<key>.+)}", str)
    ScaleDegree(m[:alterednumeral], SpelledKey(m[:key]))
end

macro sd_str(str)
    sd = ScaleDegree(str)
    :($sd)
end

SpelledPC(sd::ScaleDegree) = Acc(sd)(pcs(key(sd))[diatonic(sd)])

function ScaleDegree(pc::SpelledPC, k::SpelledKey)
    g = diatonic(pc) - diatonic(root(k))
    a = Acc(pc) - Acc(pcs(k)[g])
    ScaleDegree(g, a, k)
end

const major_mod_modes = [Major, Minor, Minor, Major, Major, Minor, Minor]
const minor_mod_modes = [Minor, Minor, Major, Minor, Minor, Major, Major]

function modulation_mode(sd::ScaleDegree)
    modes = ismajor(key(sd)) ? major_mod_modes : minor_mod_modes
    modes[diatonic(sd)]
end

function modulate(sd::ScaleDegree)
    root = SpelledPC(sd)
    mode = modulation_mode(sd)
    ScaleDegree("I", SpelledKey(root, mode))
end

end # module