module Timed

export onset, offset, duration, hasonset, hasoffset, hasduration
export skip_cost, onset_cost

"""
    onset(x)

Returns the onset of some timed object x.
"""
function onset end

"""
    offset(x)

Returns the offset of some timed object x.
"""
function offset end

"""
    duration(x)

Returns the duration of some timed object x.
"""
function duration end

"""
    hasonset(T)

Returns true if T is a timed object with an onset.
"""
function hasonset end

"""
    hasoffset(T)

Returns true if T is a timed object with an offset.
"""
function hasoffset end

"""
    hasduration(T)

Returns true if T is a timed object with a duration.
"""
function hasduration end

offset(x) = onset(x) + duration(x)
duration(x) = offset(x) - onset(x)

hasonset(::Any) = false
hasoffset(::Any) = false
hasduration(x::Any) = hasonset(x) && hasoffset(x)

# interface functionality
# =======================

## cost/distance functions
## -----------------------

"""
    skip_cost(timed1, timed2)

Returns the distance between the offset of timed1 and the onset of timed2.
"""
skip_cost(s1, s2) = onset(s2) - offset(s1)

"""
    onset_cost(timed1, timed2)
Returns the distance between the onsets of timed1 and timed2.
"""
onset_cost(s1, s2) = onset(s2) - onset(s1)

end # module
