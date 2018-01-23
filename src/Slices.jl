module Slices

import IterTools
import Base.==, Base.hash, Base.show

export Slice, unwrap_slices, slice_skip_cost, slice_onset_cost
export sg_duration_total, sg_duration_sum
export FiguredPitch, FiguredPitchClass
export pc, transpose_equiv
export re_represent_slice, pc_bag, pc_set, p_set, figured_p, figured_pc
export re_represent_slice_gram, all_as, figured_gram_p, figured_gram_pc

# general slice structure
# -----------------------

struct Slice{T, N<:Number}
    onset :: N
    duration :: N
    pitches:: T
end

==(s1::Slice, s2::Slice) =
    s1.onset == s2.onset && s1.duration == s2.duration && s1.pitches == s2.pitches

hash(s::Slice, x::UInt) = hash(s.onset, hash(s.duration, hash(s.pitches, x)))

"Returns the pitch representations in a vector of slices."
unwrap_slices(slices) = map(s -> s.pitches, slices)

"Returns the distance between the offset of s1 and the onset of s2."
slice_skip_cost(s1::Slice, s2::Slice) = s2.onset - (s1.onset + s1.duration)

"Returns the distance between the onsets of s1 and s2."
slice_onset_cost(s1::Slice, s2::Slice) = s2.onset - s1.onset

# n-grams of slices
# -----------------

"Returns the total duration of a slice n-gram (including skipped time)"
sg_duration_total(sg) = sg[end].onset + sg[end].duration - sg[1].onset

"Returns the sum of slice durations in a slice n-gram (excluding skipped time)"
sg_duration_sum(sg) = sum(map(slice -> slice.duration, sg))


# representations of pitch groups
# -------------------------------
# 
# Each of these functions expect a bag of pitches

"Helper: Turns a pitch into a pitch class."
pc(pitch::Int) = mod(pitch,12)

"Helper: change the pitch representation in a slice.
Assumes a bag of pitches representations"
re_represent_slice(f, slice::Slice{Vector{Int}}) =
    Slice(slice.onset, slice.duration, f(slice.pitches))

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

==(fp1::FiguredPitch, fp2::FiguredPitch) =
    fp1.bass == fp2.bass && fp1.figures == fp2.figures

hash(fp::FiguredPitch, x::UInt) = hash(fp.bass, hash(fp.figures, x))

function show(io::IO, fp::FiguredPitch)
    figs = sort!(collect(fp.figures))
    write(io, string(fp.bass), "^{", join(figs, ", "), "}")
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

==(fp1::FiguredPitchClass, fp2::FiguredPitchClass) =
    fp1.bass == fp2.bass && fp1.figures == fp2.figures

hash(fp::FiguredPitchClass, x::UInt) = hash(fp.bass, hash(fp.figures, x))

function show(io::IO, fp::FiguredPitchClass)
    figs = sort!(collect(fp.figures))
    write(io, "[", string(fp.bass), "]^{", join(figs, ", "), "}")
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
    re_represent_slice_gram(itr, f)

Takes an iterator over pitch bag slices `itr`,
and and a gram rerepresentation function `f`.
Returns iterator over slices rerepresented according to `f`.
`f` should take an iterator of pitch bags
and return an iterator over some other representation.
Slice onsets and durations are taken from the original slices.
"""
function re_represent_slice_gram(f, gram)
    rerep_slice(slice, repitches) = Slice(slice.onset, slice.duration, repitches)
    map(rerep_slice, gram, f(unwrap_slices(gram)))
end

"Helper: Returns an n-gram rerepresentation function obtained by mapping `f` over all elements."
all_as(f::Function) = xs -> IterTools.imap(f, xs)

"Returns a figured bass n-gram with an absolute initial bass pitch
and subsequent bass pitches relative to the first."
function figured_gram_p(gram)
    fbs = collect(all_as(figured_p)(gram))
    fst = first(fbs)
    ref = fst.bass
    relbass(fg) = FiguredPitch(fg.bass - ref, fg.figures)
    out = map(relbass, collect(fbs))
    out[1] = fst
    out
end

"Returns a figured bass n-gram with an absolute initial bass pitch class
and subsequent bass pitch classes relative (mod 12) to the first."
function figured_gram_pc(gram)
    fbs = collect(all_as(figured_pc)(gram))
    fst = first(fbs)
    ref = fst.bass
    relbass(fg) = FiguredPitchClass(pc(fg.bass - ref), fg.figures)
    out = map(relbass, collect(fbs))
    out[1] = fst
    out
end

# general methods on music structures
# -----------------------------------

"Returns a figured gram with the reference pitch set to 0.
This results in transpositional equivalence."
function transpose_equiv end

function transpose_equiv(gram::Vector{FiguredPitch})
    new = gram[:]
    new[1] = FiguredPitch(0, gram[1].figures)
    new
end

function transpose_equiv(gram::Vector{FiguredPitchClass})
    new = gram[:]
    new[1] = FiguredPitchClass(0, gram[1].figures)
    new
end

end #module
