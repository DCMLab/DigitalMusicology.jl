module PitchCollections

import Base: collect, map, ==, hash, eltype, length, show
# import ..PitchOps: pc, transposeby, transposeto
using ...DigitalMusicology

export PitchCollection
export transposeby, transposeto
export transposeequiv, refpitch, pitches, pitchiter

export PitchBag, pbag
export PitchClassBag, pcbag
export PitchSet, pset
export PitchClassSet, pcset
export FiguredBass, bass, figures
#export setbass, setfigures, updatebass, updatefigures
export FiguredPitch, FiguredPitchClass, figuredp, figuredpc

# PitchCollection
# ===============

"""
An abstract supertype for pitch collections.
Since a pitch collection should contain only one type of pitches,
`PitchCollection` is parametric on a subtype of `Pitch`.
"""
abstract type PitchCollection{P<:Pitch} end

"Transpose a pitch (collection) by some directed interval."
function transposeby end

transposeby(pitch::P, interval::P) where {P <: Pitch} = pitch+interval

"Transpose a pitch (collection) to a new reference point."
function transposeto end

transposeto(pitch::P, newref::P) where {P <: Pitch} = newref

"""
    transposeequiv(pitchcoll)

Turns a pitch collection to a representative of its transpositional equivalence class.
"""
function transposeequiv end

transposeequiv(coll::PitchCollection{P}) where P = transposeto(coll, zero(P))

"""
    refpitch(pitchcoll)

Returns a unique reference pitch for the pitch collection.
This reference should behave consistent with `transposeto` and `transposeby`

```julia
transposeto(coll, 0) == transposeby(coll, -refpitch(coll))
```
"""
function refpitch end

"""
    pitchiter(pitchcoll)

If the collection has an inner collection of all pitches,
this function returns an iterator over the inner collection.
The outer collection does not have to implement the iterator interface,
since the default implementation for `PitchCollection`s falls back to the inner iterator.
"""
function pitchiter end

"""
    pitches(pcoll)

Returns a vector of all pitches in `pcoll`
to the degree they can be reconstructed from the representation used by `pcoll`.
"""
pitches(pcoll) = collect(pitchiter(pcoll))

## some default implementations of Base methods

start(coll::PitchCollection) = start(pitchiter(coll))

next(coll::PitchCollection, state) = next(pitchiter(coll), state)

done(coll::PitchCollection, state) = done(pitchiter(coll), state)

eltype(coll::PitchCollection{P}) where P = P

## default implementations of PitchOps methods

transposeby(coll::PitchCollection{P}, int::P) where P = map(p -> p + int, coll)

transposeto(coll::PitchCollection{P}, newref::P) where P =
    transposeby(coll, newref-refpitch(coll))

# Standard Collections
# ====================

pitchiter(ps::AbstractArray{P}) where {P<:Pitch} = ps

pitchiter(ps::Set{P}) where {P<:Pitch} = ps

# Bags and Sets
# =============

## Pitch Bag
## ---------

struct PitchBag{P} <: PitchCollection{P}
    bag :: Vector{P}

    PitchBag(bag::Vector{P}) where P = new{P}(sort(bag))
end

"Represents pitches as a bag of pitches."
pbag(pitches) = PitchBag(collect(pitches))

pitchiter(pb::PitchBag) = pb.bag

### Base methods

==(pb1::PitchBag, pb2::PitchBag) = pb1.bag == pb2.bag

hash(pb::PitchBag, x::UInt) = hash(pb.bag, x)

collect(pb::PitchBag) = pb.bag

length(pb::PitchBag) = length(pb.bag)

map(f, pb::PitchBag) = PitchBag(sort(map(f, pb.bag)))

show(io::IO, pb::PitchBag) =
    write(io, "{|", join(pb.bag, ", "), "|}")

### PitchOps methods

pc(pb::PitchBag) = pcbag(collect(pb))

refpitch(pb::PitchBag) = first(pb.bag)

## Pitch Class Bag
## ---------------

struct PitchClassBag{P} <: PitchCollection{P}
    bag :: Vector{P}

    PitchClassBag(bag::Vector{P}) where P = new{P}(sort(pc.(bag)))
end

"Represents pitches as a bag (vector) of pitch classes."
pcbag(pitches) = PitchClassBag(collect(pitches))

pitchiter(pcb::PitchClassBag) = pcb.bag

### Base methods

==(pcb1::PitchClassBag, pcb2::PitchClassBag) = pcb1.bag == pcb2.bag

hash(pcb::PitchClassBag, x::UInt) = hash(pcb.bag, x)

collect(pcb::PitchClassBag) = pcb.bag

length(pcb::PitchClassBag) = length(pcb.bag)

map(f, pcb::PitchClassBag) = PitchClassBag(sort(map(pc∘f, pcb.bag)))

show(io::IO, pcb::PitchClassBag) =
    write(io, "{|", join(pcb.bag, ", "), "|}/12")

### PitchOps methods

pc(pcb::PitchClassBag) = pcb

# TODO: reference pitch for pitch class bag -> transposeto

## Pitch Set
## ---------

struct PitchSet{P} <: PitchCollection{P}
    set :: Set{P}
end

"Represent pitches as a set of absolute pitches."
pset(pitches) = PitchSet(Set(pitches))

pitchiter(ps::PitchSet) = ps.set

### Base methods

==(ps1::PitchSet, ps2::PitchSet) = ps1.set == ps2.set

hash(ps::PitchSet, x::UInt) = hash(ps.set, x)

collect(ps::PitchSet) = collect(ps.set)

length(ps::PitchSet) = length(ps.set)

map(f, ps::PitchSet) = PitchSet(Set(f(x) for x = ps.set))

show(io::IO, ps::PitchSet) =
    write(io, "{", join(sort(collect(ps.set)), ", "), "}")

### PitchOps methods

pc(ps::PitchSet) = pcset(collect(ps))

## Pitch Class Set
## ---------------

struct PitchClassSet{P} <: PitchCollection{P}
    set :: Set{P}

    PitchClassSet(set::Set{P}) where P = new{P}(Set(pc(p) for p = set))
end

"Represents pitches as a set of pitch classes."
pcset(pitches) = PitchClassSet(Set(pitches))

pitchiter(pcs::PitchClassSet) = pcs.set

### Base methods

==(pcs1::PitchClassSet, pcs2::PitchClassSet) = pcs1.set == pcs2.set

hash(pcs::PitchClassSet, x::UInt) = hash(pcs.set, x)

collect(pcs::PitchClassSet) = collect(pcs.set)

length(pcs::PitchClassSet) = length(pcs.set)

map(f, pcs::PitchClassSet) = PitchClassSet(Set(pc(f(p)) for p = pcs.set))

show(io::IO, pcs::PitchClassSet) =
    write(io, "{", join(sort(collect(pcs.set)), ", "), "}/12")

### PitchOps methods

pc(pcs::PitchClassSet) = pcs

# Figured Bass Representations
# ============================

"Represents notes as a bass pitch with (a set of) figures."
abstract type FiguredBass{P} <: PitchCollection{P} end

"Returns the bass pitch of a figured bass representation."
function bass end

"Returns the figure pitch classes of a figured bass representation.
(including 0 for the bass note)"
function figures end

(refpitch(fb::FiguredBass{P})::P) where {P} = bass(fb)

# "Returns a new figured bass with a new bass pitch (class).
# The figures are adapted to be relative to the new bass pitch"
# function setbass end

# "Returns a new figured bass with new figures."
# function setfigures end

# "Applies a function to the bass pitch of a figured bass.
# Returns a new figured bass with the new bass pitch
# and adapted figures."
# function updatebass end

# "Applies a function to the figures of a figured bass.
# Returns a new figured bass with the new figures."
# function updatefigures end

## figured: bass pitch with pitch class figures
## --------------------------------------------

struct FiguredPitch{P} <: FiguredBass{P}
    bass :: P
    figures :: PitchClassSet{P}
    
    #FiguredPitch{P}(bass::P, figures) where P =
    #    new(bass, pcset(map(p -> p - bass, figures)))
end

"""
    figuredp(pitches)

Represents pitches as a bass pitch and remaining pitch classes
relative to the bass.
"""
figuredp(pitches) =
    let bass = minimum(pitches)
        FiguredPitch(bass, pcset(map(p -> p - bass, pitches)))
    end

### FiguredPitch accessors

bass(fp::FiguredPitch) = fp.bass

figures(fp::FiguredPitch) = fp.figures

#setbass(fp::FiguredPitch{P}, b::P) where P = FiguredPitch(b, map(p -> p+bass(fp)))

### Base methods

==(fp1::FiguredPitch, fp2::FiguredPitch) =
    bass(fp1) == bass(fp2) && figures(fp1) == figures(fp2)

hash(fp::FiguredPitch, x::UInt) = hash(bass(fp), hash(figures(fp), x))

collect(fp::FiguredPitch) = collect(map(p -> p + bass(fp), figures(fp)))

length(fp::FiguredPitch) = length(figures(fp))

function show(io::IO, fp::FiguredPitch)
    figs = sort!(collect(figures(fp)))
    write(io, string(bass(fp)), "^{", join(figs, ", "), "}")
end

### PitchOps methods

pc(fp::FiguredPitch) = FiguredPitchClass(pc(bass(fp)), figures(fp))

transposeby(fp::FiguredPitch{P}, int::P) where P =
    FiguredPitch(bass(fp)+int, figures(fp))

transposeto(fp::FiguredPitch{P}, newref::P) where P =
    FiguredPitch(newref, figures(fp))

## figured: bass pitch class with pitch class figures
## --------------------------------------------------

struct FiguredPitchClass{P} <: FiguredBass{P}
    bass :: P
    figures :: PitchClassSet{P}

    FiguredPitchClass(bass::P, figures::PitchClassSet{P}) where P =
        new{P}(pc(bass), figures)
end

"""
    figuredpc(pitches)

Represents pitches as a bass pitch class and remaining pitch classes
relative to the bass.
"""
figuredpc(pitches) =
    let figp = figuredp(pitches)
        FiguredPitchClass(bass(figp), figures(figp))
    end

### FiguredPitch accessors

bass(fpc::FiguredPitchClass) = fpc.bass

figures(fpc::FiguredPitchClass) = fpc.figures

### Base methods

==(fp1::FiguredPitchClass, fp2::FiguredPitchClass) =
    bass(fp1) == bass(fp2) && figures(fp1) == figures(fp2)

hash(fpc::FiguredPitchClass, x::UInt) = hash(bass(fpc), hash(figures(fpc), x))

collect(fpc::FiguredPitchClass) = collect(map(p -> p + bass(fpc), figures(fpc)))

length(fpc::FiguredPitchClass) = length(figures(fpc))

function show(io::IO, fp::FiguredPitchClass)
    figs = sort!(collect(figures(fp)))
    write(io, "[", string(bass(fp)), "]^{", join(figs, ", "), "}")
end

### PitchOps methods

pc(fpc::FiguredPitchClass) = fpc

transposeby(fpc::FiguredPitchClass{P}, int::P) where P =
    FiguredPitchClass(pc(bass(fpc)+int), figures(fpc))

transposeto(fpc::FiguredPitchClass{P}, newref::P) where P =
    FiguredPitch(pc(newref), figures(fpc))

end # module
