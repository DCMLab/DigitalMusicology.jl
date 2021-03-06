module Grams

using ..GatedQueues: GatedQueue, gatedq, release
using FunctionalCollections
using IterTools: groupby, @ifsomething

export grams, scapes, mapscapes
export skipgrams, indexskipgrams

const List = FunctionalCollections.AbstractList

# Grams and Scapes
# ================

"""
    grams(arr, n)

Return all `n`-grams in `arr`.
`n` must be positive, otherwise an error is thrown.

# Examples

```julia-repl
julia> grams([1,2,3], 2)
2-element Array{Array{Int64,1},1}:
 [1, 2]
 [2, 3]
```
"""
function grams(arr::A, n::Int) where {A <: AbstractArray}
    @assert n>0
    l = size(arr, 1)
    [ arr[i:(i+n-1)] for i=1:(l-n+1) ]
end

"""
    scapes(arr)

Return all `n`-grams in `arr` for `n=1:size(arr, 1)`.

# Examples

```julia-repl
julia> scapes([1,2,3])
3-element Array{Array{Array{Int64,1},1},1}:
 Array{Int64,1}[[1], [2], [3]]
 Array{Int64,1}[[1, 2], [2, 3]]
 Array{Int64,1}[[1, 2, 3]]
```
"""
scapes(arr::A) where {A <: AbstractArray} =
    [ grams(arr, n) for n=1:size(arr,1) ]

"""
    mapscapes(f, arr)

Map `f` over all `n`-grams in arr for `n=1:size(arr, 1)`.
"""
mapscapes(f::Function, arr::A) where {A <: AbstractArray} =
    [ map(f, grams(arr, n)) for n=1:size(arr,1) ]

# Skipgrams Iterator
# ==================

abstract type SkipGramItr{T} end

abstract type SkipGramItrState{T} end

struct SkipGramFastItr{T} <: SkipGramItr{T}
    input
    k :: Float64
    n :: Int
    cost :: Function
    pred :: Function
    bias :: Float64
end

const SGPrefix{T} = Tuple{Int, Float64, plist{T}}

struct SkipGramFastItrState{T} <: SkipGramItrState{T}
    instate  # :: Union{I,Nothing} # state of input iterator
    prefixes #:: Vector{SGPrefix{T}}    # list of prefixes
    out      #:: Vector{Vector{T}} #List{Vector{T}} # found grams
    outstate #:: Int
end

# exactly the same as SkipGramFastItr{T}
struct SkipGramStableItr{T} <: SkipGramItr{T}
    input
    k :: Float64
    n :: Int
    cost :: Function
    pred :: Function
    bias :: Float64
end

"""
    skipgrams(input, k, n, cost [, pred] [, element_type=type] [, stable=false] [, p=1.0])

Returns an iterator over all generalized `k`-skip-`n`-grams found in `input`.

Instead of defining skips as index steps > 1, a general `cost` function is used.
`k` is then an upper bound to the sum of all distances between consecutive elements in the gram.

The input needs to be iterable and monotonous with respect to the cost to a
previous element:

    ∀ i<j<l: cost(input[i], input[j]) ≤ cost(input[i], input[l])

From this we know that if the current element increases the skip cost of some
unfinished gram (prefix) to more than `k`,
then all following elements will increase the cost at least as much,
so we can discard the prefix.

An optional predicate function can be provided to filter potential skipgrams early.
The predicate takes a `PersistentList` of input elements *in reverse order*
(i.e., starting with the element that was added last).
The predicate is applied to every prefix, so the list will have <=n elements.
By default, all sequences of input elements are valid.

If `element_type` is provided, the resulting iterator will have a corresponding `eltype`.
If not, it will try to guess the element type based on the input's `eltype`.

If `stable` is `true`, then the skipgrams will be ordered with respect to the position
of their first element in the input stream.
If `stable` is `false` (default), no particular order is guaranteed.

The parameter `p` allows to decide randomly (with probability p) whether a skipgram is
included in the output in cases where the full list of skipgrams is to long.
A coin with bias p^(1/n) will be flipped for every prefix applying to all completions
of that prefix.
Only if the coin flip for every prefix is positive, the skipgram will be included.
This allows to save computation time by throwing away all completions of a discarded prefix,
but it might introduce artifacts for the same reason.

# Examples

```julia
function indexskipgrams(itr, k, n)
    cost(x, y) = y[1] - x[1] - 1
    grams = skipgrams_itr(enumerate(itr), k, n, cost)
    map(sg -> map(x -> x[2], sg), grams)
end
```
"""
function skipgrams(itr, k::Float64, n::Int, cost::Function,
                   pred::Function = (x -> true);
                   element_type=eltype(itr),
                   stable=false,
                   p=1.0)
    bias = p^(1/(n-1))
    if stable
        SkipGramStableItr{element_type}(itr, k, n, cost, pred, bias)
    else
        SkipGramFastItr{element_type}(itr, k, n, cost, pred, bias)
    end
end

## unstable skipgrams
## ------------------

function process_candidate(itr::SkipGramFastItr{T},
                           st::SkipGramFastItrState{T}) where {T}
    # define helpers
    mk_prefix(x) = (itr.n-1, 0.0, plist{T}([x]))
    total_cost(pfx, x) = pfx[2] + itr.cost(first(pfx[3]), x)
    extend_prefix(pfx, x) = (pfx[1]-1, total_cost(pfx, x), cons(x,pfx[3]))
    prefix_complete(pfx) = pfx[1] <= 0
    prefix_to_gram(pfx::SGPrefix{T}) :: Vector{T} = reverse!(collect(pfx[3]))

    # 1. generate candidates
    candidate, nextst = @ifsomething if st.instate == nothing
        iterate(itr.input)
    else
        iterate(itr.input, st.instate)
    end

    # 2. remove prefixes that cannot be completed anymore
    old_closed = filter(p -> total_cost(p, candidate) <= itr.k, st.prefixes)

    # check for compatibility with candidate
    extendable = if itr.bias==1.0 # stochastic?
        filter(p -> itr.pred(cons(candidate, p[3])), old_closed)
    else # flip coin before extending
        filter(p -> itr.pred(cons(candidate, p[3])) && rand() < itr.bias, old_closed)
    end

    # 3. extend prefixes
    extended = map(p -> extend_prefix(p, candidate), extendable)
    push!(extended, mk_prefix(candidate))

    # 4. collect completed grams
    # out = plist{Vector{T}}(map(prefix_to_gram, filter(prefix_complete, extended)))
    out = map(prefix_to_gram, filter(prefix_complete, extended))

    # 5. collect new prefixes
    # newpfx     = mk_prefix(candidate)
    # incomplete = filter(!prefix_complete, extended)
    # nextpfxs   = conj(old_closed ∪ incomplete, newpfx)
    nextpfxs = append!(old_closed, filter!(!prefix_complete, extended))
    
    #...
    outstart = iterate(out)
    if outstart == nothing
        fstout, outst = nothing, nothing
    else
        fstout, outst = outstart
    end
    fstout, SkipGramFastItrState{T}(nextst, nextpfxs, out, outst)
end

function newgrams(itr::SkipGramFastItr{T}, st::SkipGramFastItrState{T}) where T
    out = nothing
    while out == nothing
        out, st = @ifsomething process_candidate(itr, st)
    end
    out, st
end

## iterator interface

function Base.iterate(itr::SkipGramFastItr{T}) where T
    init = SkipGramFastItrState{T}(
        nothing,
        Vector{SGPrefix{T}}(),
        Vector{Vector{T}}(),
        0
    )
    newgrams(itr, init)
end

nextstate(st::SkipGramFastItrState{T}, rest::Int) where {T} =
    SkipGramFastItrState{T}(st.instate, st.prefixes, st.out, rest)

function Base.iterate(itr::SkipGramItr{T}, st::SkipGramItrState{T}) where {T}
    nxt = iterate(st.out, st.outstate)
    if nxt != nothing
        gram, rest = nxt
        nxtst = nextstate(st, rest)
        gram, nxtst
    else
        newgrams(itr,st)
    end
end

Base.IteratorSize(itrtype::Type{I}) where {I<:SkipGramItr} = Base.SizeUnknown()

Base.IteratorEltype(itrtype::Type{I}) where {I<:SkipGramItr} = Base.HasEltype()

Base.eltype(itrtype::Type{SkipGramFastItr{T}}) where {T} = Vector{T}
Base.eltype(itrtype::Type{SkipGramStableItr{T}}) where {T} = Vector{T}


## stable skipgram iterator
## ------------------------
## This is a bit more complicated than the normal skipgram iterator
## Instead of just pushing out all generated grams as soon as they are completed,
## they are held back until no prefixes are left that start before the finished gram.
## This way, the the first elements of the resulting skipgrams have the
## same order in the in output stream as in the input stream.

const SGSPrefix{T} = Tuple{Int, Float64, plist{T}, Int}

# like SkipGramFastItrState but with additional information
struct SkipGramStableItrState{T} <: SkipGramItrState{T}
    instate # :: Union{Nothing,I}
    prefixes :: Vector{SGSPrefix{T}}
    queue :: GatedQueue{Int, Vector{Vector{T}}}
    index :: Int
    out
    outstate
end

function enqueue_grams(q::GatedQueue{Int,Vector{T}}, xs::Vector) where {T}
    sort!(xs, by=first) # allows groupby
    groups = groupby(first, xs)

    # could this be improved wrt. allocation?
    entries = plist{Tuple{Int, Vector{T}}}([(g[1][1], map(x -> x[2], g)) for g in groups])
    newq = GatedQueue{Int, Vector{T}}(entries)

    merge(vcat, q, newq)
end

function process_candidate(itr::SkipGramStableItr{T},
                           st::SkipGramStableItrState{T}) where {T}
    # define helpers
    mk_prefix(x) = (itr.n-1, 0.0, plist{T}([x]), st.index)
    total_cost(pfx, x) = pfx[2] + itr.cost(first(pfx[3]), x)
    extend_prefix(pfx, x) = (pfx[1]-1, total_cost(pfx, x), cons(x,pfx[3]), pfx[4])
    prefix_complete(pfx) = pfx[1] <= 0
    prefix_to_gram(pfx::SGSPrefix{T}) :: Pair{Int,Vector{T}} =
        pfx[4] => reverse!(collect(pfx[3]))

    # 1. generate candidates
    candidate, nextst = @ifsomething if st.instate == nothing
        iterate(itr.input)
    else
        iterate(itr.input, st.instate)
    end

    # 2. remove prefixes that cannot be completed anymore
    old_closed = filter(p -> total_cost(p, candidate) <= itr.k, st.prefixes)

    # release grams that cannot be preceded
    # why is there no key argument for minimum???
    gate = st.index
    for oc in old_closed
        if oc[4] < gate
            gate = oc[4]
        end
    end
    # release all safe grams from the queue
    released, qrel = release(st.queue, gate)
    if isempty(released)
        out = Vector{Vector{T}}()
    else
        out = Iterators.flatten(released)
    end

    # check for compatibility with candidate
    extendable = if itr.bias==1.0 # stochastic?
        filter(p -> itr.pred(cons(candidate, p[3])), old_closed)
    else # flip coin before extending
        filter(p -> itr.pred(cons(candidate, p[3])) && rand() < itr.bias, old_closed)
    end

    # 3. extend prefixes
    extended = map(p -> extend_prefix(p, candidate), extendable)
    push!(extended, mk_prefix(candidate))

    # 4. collect completed grams
    newgrams = map(prefix_to_gram, filter(prefix_complete, extended))
    # add all new grams to the queue
    qnew = enqueue_grams(qrel, newgrams)
    
    # 5. collect new prefixes
    nextpfxs = append!(old_closed, filter!(!prefix_complete, extended))
    
    #...
    outstart = iterate(out)
    if outstart == nothing
        fstout, outst = nothing, nothing
    else
        fstout, outst = outstart
    end
    fstout, SkipGramStableItrState{T}(nextst, nextpfxs, qnew, st.index+1, out, outst)
end

function Base.iterate(itr::SkipGramStableItr{T}) where T
    init = SkipGramStableItrState{T}(
        nothing,
        Vector{SGSPrefix{T}}(),
        gatedq(Int, Vector{Vector{T}}),
        1,
        Vector{Vector{T}}(),
        0
    )
    newgrams(itr, init)
end

function newgrams(itr::SkipGramStableItr{T}, st::SkipGramStableItrState{T}) where {T}
    out = nothing
    while out == nothing
        nxt = process_candidate(itr, st)
        if nxt == nothing
            if isempty(st.queue)
                return nothing
            else
                released, qnew = release(st.queue, st.index)
                out = Iterators.flatten(released)
                fstout, outst = iterate(out)
                return fstout, SkipGramStableItrState{T}(
                    st.instate,
                    st.prefixes,
                    qnew,
                    st.index,
                    out,
                    outst
                )
            end
        else
            out, st = nxt
        end
    end
    out, st
end

nextstate(st::SkipGramStableItrState{T}, rest) where {T} =
    SkipGramStableItrState{T}(st.instate, st.prefixes, st.queue, st.index, st.out, rest)

# standard skipgrams
# ------------------

indexcost(x::Tuple{Int,T}, y::Tuple{Int,U}) where {T, U} = Float64(y[1] - x[1] - 1)

# skipgram iterator test
"""
    indexskipgrams(itr, k, n)

Return all `k`-skip-`n`-grams over `itr`, with skips based on indices.
For a custom cost function, use [`skipgrams`](@ref).

# Examples

```julia-repl
julia> indexskipgrams([1,2,3,4,5], 2, 2)
9-element Array{Any,1}:
 Any[1, 2]
 Any[1, 3]
 Any[2, 3]
 Any[1, 4]
 Any[2, 4]
 Any[3, 4]
 Any[2, 5]
 Any[3, 5]
 Any[4, 5]
```
"""
function indexskipgrams(itr, k::Int, n::Int; stable=false)
    map(sg -> map(x -> x[2], sg),
        skipgrams(enumerate(itr), # index is used for cost
                  Float64(k), n,  # as usual
                  indexcost,     # dist: more than "step" wrt indices
                  stable=stable)) # keep order?
end

end # module

# Legace Code
# ===========

# skipgrams on arrays and channels
# --------------------------------

# """
#     skipgrams_general(itr, k, n, cost [, pred])

# Returns all generalized `k`-skip-`n`-grams.

# Instead of defining skips as index steps > 1, a general distance function can be supplied.
# `k` is then an upper bound to the sum of all distances between consecutive elements in the gram.

# The input needs to be monotonous with respect to the distance to a
# previous element:

#     ∀ i<j<l: dist(itr[i], itr[j]) ≤ dist(itr[i], itr[l])

# From this we know that if the current element increases the skip cost of some
# unfinished gram (prefix) to more than `k`,
# then all following elements will increase the cost at least as much,
# so we can discard the prefix.

# The `input` should be an iterable and will be consumed lazily
# as the skipgram iterator is consumed.

# An optional predicate function can be provided to test potential neighbors in a skipgram.
# By default, all input elements are allowed to be neighbors.

# # Examples

# ```julia
# function skipgrams(itr, k, n)
#     cost(x, y) = y[1] - x[1] - 1
#     grams = skipgrams_general(enumerate(itr), k, n, cost)
#     map(sg -> map(x -> x[2], sg), grams)
# end
# ```
# """
# function skipgrams_general(itr, k::Float64, n::Int, cost::Function,
#                            pred::Function = ((x1, x2) -> true);
#                            element_type = eltype(itr))
#     # helpers
#     mk_prefix(x) = (n-1, 0.0, plist{element_type}([x]))
#     total_cost(pfx, x) = pfx[2] + cost(first(pfx[3]), x)
#     extend_prefix(pfx, x) = (pfx[1]-1, total_cost(pfx, x), cons(x,pfx[3]))
#     prefix_complete(pfx) = pfx[1] <= 0
#     prefix_to_gram(pfx) = reverse!(collect(pfx[3]))

#     # initial values (like ugly, mutable accumulators)
#     prefixes = Vector{Tuple{Int,Float64,PersistentList{element_type}}}()
#     found_grams = Vector{Vector{element_type}}()
    
#     # generate candidates
#     for candidate in itr
#         # remove prefixes that cannot be completed anymore
#         old_closed = filter(p -> total_cost(p, candidate) <= k, prefixes)

#         # check for compatibility with candidate
#         extendable = filter(p -> pred(first(p[3]), candidate), old_closed)
        
#         # extend prefixes
#         extended = map(p -> extend_prefix(p, candidate), extendable)

#         # add complete prefixes to found
#         append!(found_grams, map(prefix_to_gram,
#                                  filter(prefix_complete, extended)))
        
#         # add incomplete prefixes to prefixes
#         prefixes = append!(old_closed, filter(!prefix_complete, extended))

#         # open new prefix for candidate
#         push!(prefixes, mk_prefix(candidate))
#     end

#     # return found skip grams
#     found_grams
# end

# # skip-grams channel
# # ------------------

# function skipgrams_channel(itr, k::Float64, n::Int, cost::Function,
#                            pred::Function = ((x1, x2) -> true))
#     # helpers
#     mk_prefix(x) = (n-1, 0.0, plist{eltype(itr)}([x]))
#     total_cost(pfx, x) = pfx[2] + cost(first(pfx[3]), x)
#     extend_prefix(pfx, x) = (pfx[1]-1, total_cost(pfx, x), cons(x,pfx[3]))
#     prefix_complete(pfx) = pfx[1] <= 0
#     prefix_to_gram(pfx) = reverse!(collect(pfx[3]))
    
#     Channel() do c
#         prefixes = []

#         # generate candidates
#         for candidate in itr
#             # remove prefixes that cannot be completed anymore
#             old_closed = filter(p -> total_cost(p, candidate) <= k, prefixes)

#             # check for compatibility with candidate
#             extendable = filter(p -> pred(first(p[3]), candidate), old_closed)

#             # extend prefixes
#             extended = map(p -> extend_prefix(p, candidate), extendable)
        
#             # add incomplete prefixes to prefixes
#             prefixes = append!(old_closed, filter(!prefix_complete, extended))
            
#             # open new prefix for candidate
#             push!(prefixes, mk_prefix(candidate))

#             # add complete prefixes to found
#             map(p -> put!(c, prefix_to_gram(p)), filter(prefix_complete, extended))
#         end
#     end
# end

# indexskipgrams on arrays and channels
# -------------------------------------

# function skipgramsv(itr, k::Int, n::Int)
#     map(sg -> map(x -> x[2], sg),
#         skipgrams_general(enumerate(itr), # index is used for cost
#                           Float64(k), n,  # as usual
#                           index_cost))    # dist: more than "step" wrt indices
# end

# # skipgram channel test
# function skipgramsc(itr, k::Int, n::Int)
#     map(sg -> map(x -> x[2], sg),
#         skipgrams_channel(enumerate(itr), # index is used for cost
#                       Float64(k), n,  # as usual
#                       index_cost))    # dist: more than "step" wrt indices
# end
