module Slices

import Base.==, Base.hash, Base.show
import DigitalMusicology.Timed: onset, offset, duration, hasonset, hasoffset, hasduration

export Slice, content
export setonset, setduration, setoffset, setcontent
export update_onset, update_duration, update_offset, update_content
export unwrap_slices, sg_duration_total, sg_duration_sum
# export re_represent_slice_gram, all_as, figured_gram_p, figured_gram_pc

# general slice structure
# -----------------------

"""
    Slice(onset::N, duration::N, content::T) where {N<:Number, T}

A slice of a pitches in a piece.
Timing information (type `N`) is encoded as onset and duration
with methods for obtaining and modifying the offset directly.
The content of a slice is typically some representation of
simultaneously sounding pitches (type `T`).
"""
struct Slice{N<:Number, T}
    onset :: N
    duration :: N
    content:: T
end

==(s1::Slice, s2::Slice) =
    s1.onset == s2.onset && s1.duration == s2.duration && s1.content == s2.content

hash(s::Slice, x::UInt) = hash(s.onset, hash(s.duration, hash(s.content, x)))

function show(io::IO, s::Slice)
    write(io, string("Slice<", onset(s), "-", duration(s), "-", offset(s), ">("))
    show(io, content(s))
    write(io, ")")
end

onset(s::Slice{N,T}) where {T, N} = s.onset

duration(s::Slice{N,T}) where {T, N} = s.duration

offset(s::Slice{N,T}) where {T, N} = s.onset + s.duration

hasonset(::Type{Slice}) = true
hasoffset(::Type{Slice}) = true
hasduration(::Type{Slice}) = true

"Returns the content of slice s."
content(s::Slice{N,T}) where {T, N} = s.content

"""
    setonset(s, on)

Returns a new slice with onset `on`.
"""
setonset(s::Slice{N,T}, on::N) where {T, N} =
    Slice(on, duration(s), content(s))

"""
    setduration(dur::N, s)

Returns a new slice with duration `dur`.
"""
setduration(s::Slice{N,T}, dur::N) where {T, N} =
    Slice(onset(s), dur, content(s))

"""
    setoffset(off::N, s)

Returns a new slice with offset `off`.
"""
setoffset(s::Slice{N,T}, off::N) where {T, N} =
    setduration(s, off - onset(s))

"""
    setcontent(ps, s)

Returns a new slice with content `ps`.
"""
setcontent(s::Slice{N,T}, ps) where {N, T} =
    Slice(onset(s), duration(s), ps)

"""
    update_onset(f::Function, s)

Returns a new slice onset `f(onset(s))`.
"""
update_onset(f::Function, s::Slice{N,T}) where {N, T} =
    setonset(s, f(onset(s)))

"""
    update_duration(f::Function, s)

Returns a new slice with duration `f(duration(s))`.
"""
update_duration(f::Function, s::Slice{N,T}) where {N, T} =
    setduration(s, f(duration(s)))

"""
    update_offset(f::Function, s)

Returns a new slice with offset `f(offset(s))`.
"""
update_offset(f::Function, s::Slice{N,T}) where {N, T} =
    setoffset(s, f(offset(s)))

"""
    update_content(f::Function, s::Slice)

Returns a new slice with content `f(content(s))`.
"""
update_content(f::Function, s::Slice{N,T}) where {N, T} =
    setcontent(s, f(content(s)))

# n-grams of slices
# -----------------

"Returns the pitch representations in a vector of slices."
unwrap_slices(slices) = map(content, slices)

"Returns the total duration of a slice n-gram (including skipped time)"
sg_duration_total(sg) = offset(sg[end]) - onset(sg[1])

"Returns the sum of slice durations in a slice n-gram (excluding skipped time)"
sg_duration_sum(sg) = sum(map(duration, sg))

# representations of pitch group n-grams
# --------------------------------------
#
# All functions in this section expect an iterator over bags of pitches
# and return an iterator over some representation

# """
#     re_represent_slice_gram(itr, f)

# Takes an iterator over pitch bag slices `itr`,
# and and a gram rerepresentation function `f`.
# Returns iterator over slices rerepresented according to `f`.
# `f` should take an iterator of pitch bags
# and return an iterator over some other representation.
# Slice onsets and durations are taken from the original slices.
# """
# function re_represent_slice_gram(f, slices)
#     #rerep_slice(slice, repitches) = Slice(onset(slice), duration(slices), repitches)
#     map(setcontent, slices, f(unwrap_slices(gram)))
# end

# "Helper: Returns an n-gram rerepresentation function obtained by mapping `f` over all elements."
# all_as(f::Function) = xs -> map(f, xs)

# "Returns a figured bass n-gram with an absolute initial bass pitch
# and subsequent bass pitches relative to the first."
# function figured_gram_p(gram)
#     fbs = collect(all_as(figured_p)(gram))
#     fst = first(fbs)
#     ref = fst.bass
#     relbass(fg) = FiguredPitch(fg.bass - ref, fg.figures)
#     out = map(relbass, collect(fbs))
#     out[1] = fst
#     out
# end

# "Returns a figured bass n-gram with an absolute initial bass pitch class
# and subsequent bass pitch classes relative (mod 12) to the first."
# function figured_gram_pc(gram)
#     fbs = collect(all_as(figured_pc)(gram))
#     fst = first(fbs)
#     ref = fst.bass
#     relbass(fg) = FiguredPitchClass(pc(fg.bass - ref), fg.figures)
#     out = map(relbass, collect(fbs))
#     out[1] = fst
#     out
# end

# # general methods on music structures
# # -----------------------------------

# "Returns a figured gram with the reference pitch set to 0.
# This results in transpositional equivalence."
# function transpose_equiv end

# function transpose_equiv(gram::Vector{FiguredPitch})
#     new = gram[:]
#     new[1] = FiguredPitch(0, gram[1].figures)
#     new
# end

# function transpose_equiv(gram::Vector{FiguredPitchClass})
#     new = gram[:]
#     new[1] = FiguredPitchClass(0, gram[1].figures)
#     new
# end

end #module
