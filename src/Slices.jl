module Slices

import IterTools

export Slice, FiguredPitch, FiguredPitchClass
export pc, pc_bag, pc_set, p_set, figured_p, figured_pc
export re_represent_slices, all_as, figured_gram_p, figured_gram_pc

# general slice structure
# -----------------------

struct Slice{T, N<:Number}
    onset :: N
    duration :: N
    pitches:: T
end

# representations of pitch groups
# -------------------------------
# 
# Each of these functions expect a bag of pitches

"Helper: Turns a pitch into a pitch class."
pc(pitch::Int) = mod(pitch,12)

# TODO: define types for representations or use standard structures?
# - standard structures are simpler
# - new types are unambigous and can be dispatched on, better abstraction
#   - done for figured bass representations


"Represents pitches as a bag of pitch classes."
pc_bag(pitches::Vector{Int}) = map(pc, pitches)

"Represents pitches as a set of pitch classes."
pc_set(pitches::Vector{Int}) = Set{Int}(pc_bag(pitches))

"Represent pitches as a set of absolute pitches."
p_set(pitches::Vector{Int}) = Set{Int}(pitches)

struct FiguredPitch
    bass :: Int
    figures :: Set{Int}
end

"Represents pitches as a bass pitch and remaining pitch classes \
relative to the bass."
figured_p(pitches::Vector{Int}) =
    let bass = minimum(pitches)
        FiguredPitch(bass, Set{Int}(map(p -> pc(p - bass), pitches)))
    end

struct FiguredPitchClass
    bass :: Int
    figures :: Set{Int}
end

"Represents pitches as a bass pitch class and remaining pitch classes \
relative to the bass."
figured_pc(pitches::Vector{Int}) =
    let figp = figured_p(pitches)
        FiguredPitchClass(pc(figp.bass), figp.figures)
    end

# representations of pitch group n-grams
# --------------------------------------
#
# All functions in this section expect an iterator over bags of pitches
# and return an iterator over some representation

"""
    re_represent_slices(itr, f)

Takes an iterator over pitch bag slices `itr`,
and and a gram rerepresentation function `f`.
Returns iterator over slices rerepresented according to `f`.
`f` should take an iterator of pitch bags
and return an iterator over some other representation.
Slice onsets and durations are taken from the original slices.
"""
function re_represent_slices(itr, f)
    rerep_slice(slice, repitches) = Slice(slice.onset, slice.duration, repitches)
    IterTools.imap(rerep_slice, itr, f(IterTools.imap(s -> s.pitches, itr)))
end

"Helper: Returns an n-gram rerepresentation function obtained by mapping `f` over all elements."
all_as(f::Function) = xs -> IterTools.imap(f, xs)

"Returns a figured bass n-gram with an absolute initial bass pitch
and subsequent bass pitches relative to the first."
function figured_gram_p(gram)
    fbs = all_as(figured_p)(gram)
    fst = first(fbs)
    ref = fst.bass
    relbass(fg) = FiguredPitch(fg.bass - ref, fg.figures)
    IterTools.chain([fst], IterTools.imap(relbass, Iterators.drop(fbs, 1)))
end

"Returns a figured bass n-gram with an absolute initial bass pitch class
and subsequent bass pitch classes relative (mod 12) to the first."
function figured_gram_pc(gram)
    fbs = all_as(figured_pc)(gram)
    fst = first(fbs)
    ref = fst.bass
    relbass(fg) = FiguredPitchClass(pc(fg.bass - ref), fg.figures)
    IterTools.chain([fst], IterTools.imap(relbass, Iterators.drop(fbs, 1)))
end

# general methods on music structures
# -----------------------------------

# "Returns a figured gram with the reference pitch set to 0.
# This results in transpositional equivalence."
# transpose_equiv_figured_gram()

end #module
