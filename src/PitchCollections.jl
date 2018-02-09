module PitchCollections

import Base: collect, map, ==, hash, start, done, next, eltype, length, show
import DigitalMusicology.PitchOps: pc, transpose_by, transpose_to
using DigitalMusicology

export PitchCollection
export transpose_equiv, refpitch

export PitchBag, p_bag
export PitchClassBag, pc_bag
export PitchSet, p_set
export PitchClassSet, pc_set
export FiguredBass, bass, figures
#export setbass, setfigures, update_bass, update_figures
export FiguredPitch, FiguredPitchClass, figured_p, figured_pc

# PitchCollection
# ===============

"""
An abstract supertype for pitch collections.
Since a pitch collection should contain only one type of pitches,
`PitchCollection` is parametric on a subtype of `Pitch`.
"""
abstract type PitchCollection{P<:Pitch} end

"""
    transpose_equiv(pitch_coll)

Turns a pitch collection to a representative of its transpositional equivalence class.
"""
function transpose_equiv end

transpose_equiv(coll::PitchCollection{P}) where P = transpose_to(coll, zero(P))

"""
    refpitch(pitch_coll)

Returns a unique reference pitch for the pitch collection.
This reference should behave consistent with `transpose_to` and `transpose_by`

```julia
transpose_to(coll, 0) == transpose_by(coll, -refpitch(coll))
```
"""
function refpitch end

"""
    inner_iterator(pitch_coll)

Does this already exist?
If the collection has an inner collection of all pitches,
this function returns an iterator over the inner collection.
The outer collection does not have to implement the iterator interface,
since the default implementation for `PitchCollection`s falls back to the inner iterator.
"""
function inner_iterator end

## some default implementations of Base methods

start(coll::PitchCollection) = start(inner_iterator(coll))

next(coll::PitchCollection, state) = next(inner_iterator(coll), state)

done(coll::PitchCollection, state) = done(inner_iterator(coll), state)

eltype(coll::PitchCollection{P}) where P = P

## default implementations of PitchOps methods

transpose_by(coll::PitchCollection{P}, int::P) where P = map(p -> p + int, coll)

transpose_to(coll::PitchCollection{P}, newref::P) where P =
    transpose_by(coll, newref-refpitch(coll))

# Bags and Sets
# =============

## Pitch Bag
## ---------

struct PitchBag{P} <: PitchCollection{P}
    bag :: Vector{P}

    PitchBag(bag::Vector{P}) where P = new{P}(sort(bag))
end

"Represents pitches as a bag of pitches."
p_bag(pitches) = PitchBag(collect(pitches))

inner_iterator(pb::PitchBag) = pb.bag

### Base methods

==(pb1::PitchBag, pb2::PitchBag) = pb1.bag == pb2.bag

hash(pb::PitchBag, x::UInt) = hash(pb.bag, x)

collect(pb::PitchBag) = pb.bag

length(pb::PitchBag) = length(pb.bag)

map(f, pb::PitchBag) = PitchBag(sort(map(f, pb.bag)))

show(io::IO, pb::PitchBag) =
    write(io, "{|", join(pb.bag, ", "), "|}")

### PitchOps methods

pc(pb::PitchBag) = pc_bag(collect(pb))

refpitch(pb::PitchBag) = first(pb.bag)

## Pitch Class Bag
## ---------------

struct PitchClassBag{P} <: PitchCollection{P}
    bag :: Vector{P}

    PitchClassBag(bag::Vector{P}) where P = new{P}(sort(pc.(bag)))
end

"Represents pitches as a bag (vector) of pitch classes."
pc_bag(pitches) = PitchClassBag(collect(pitches))

inner_iterator(pcb::PitchClassBag) = pcb.bag

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

# TODO: reference pitch for pitch class bag -> transpose_to

## Pitch Set
## ---------

struct PitchSet{P} <: PitchCollection{P}
    set :: Set{P}
end

"Represent pitches as a set of absolute pitches."
p_set(pitches) = PitchSet(Set(pitches))

inner_iterator(ps::PitchSet) = ps.set

### Base methods

==(ps1::PitchSet, ps2::PitchSet) = ps1.set == ps2.set

hash(ps::PitchSet, x::UInt) = hash(ps.set, x)

collect(ps::PitchSet) = collect(ps.set)

length(ps::PitchSet) = length(ps.set)

map(f, ps::PitchSet) = PitchSet(map(f, ps.set))

show(io::IO, ps::PitchSet) =
    write(io, "{", join(sort(collect(ps.set)), ", "), "}")

### PitchOps methods

pc(ps::PitchSet) = pc_set(collect(ps))

## Pitch Class Set
## ---------------

struct PitchClassSet{P} <: PitchCollection{P}
    set :: Set{P}

    PitchClassSet(set::Set{P}) where P = new{P}(map(pc,set))
end

"Represents pitches as a set of pitch classes."
pc_set(pitches) = PitchClassSet(Set(pitches))

inner_iterator(pcs::PitchClassSet) = pcs.set

### Base methods

==(pcs1::PitchClassSet, pcs2::PitchClassSet) = pcs1.set == pcs2.set

hash(pcs::PitchClassSet, x::UInt) = hash(pcs.set, x)

collect(pcs::PitchClassSet) = collect(pcs.set)

length(pcs::PitchClassSet) = length(pcs.set)

map(f, pcs::PitchClassSet) = PitchClassSet(Set(map(pc∘f, pcs.set)))

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
# function update_bass end

# "Applies a function to the figures of a figured bass.
# Returns a new figured bass with the new figures."
# function update_figures end

## figured: bass pitch with pitch class figures
## --------------------------------------------

struct FiguredPitch{P} <: FiguredBass{P}
    bass :: P
    figures :: PitchClassSet{P}
    
    #FiguredPitch{P}(bass::P, figures) where P =
    #    new(bass, pc_set(map(p -> p - bass, figures)))
end

"Represents pitches as a bass pitch and remaining pitch classes \
relative to the bass."
figured_p(pitches) =
    let bass = minimum(pitches)
        FiguredPitch(bass, pc_set(map(p -> p - bass, pitches)))
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

transpose_by(fp::FiguredPitch{P}, int::P) where P =
    FiguredPitch(bass(fp)+int, figures(fp))

transpose_to(fp::FiguredPitch{P}, newref::P) where P =
    FiguredPitch(newref, figures(fp))

## figured: bass pitch class with pitch class figures
## --------------------------------------------------

struct FiguredPitchClass{P} <: FiguredBass{P}
    bass :: P
    figures :: PitchClassSet{P}

    FiguredPitchClass(bass::P, figures::PitchClassSet{P}) where P =
        new{P}(pc(bass), figures)
end

"Represents pitches as a bass pitch class and remaining pitch classes \
relative to the bass."
figured_pc(pitches) =
    let figp = figured_p(pitches)
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

transpose_by(fpc::FiguredPitchClass{P}, int::P) where P =
    FiguredPitchClass(pc(bass(fpc)+int), figures(fpc))

transpose_to(fpc::FiguredPitchClass{P}, newref::P) where P =
    FiguredPitch(pc(newref), figures(fpc))

end # module
