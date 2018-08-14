module Helpers

import Base: iterate, IteratorEltype, IteratorSize, eltype, length, size
using IterTools: @ifsomething
using FunctionalCollections
using Ratios

export coprime, getrec, parserational
export witheltype, takewhile, dropwhile

# Misc
# ====

function coprime(r::SimpleRatio{T}) where {T<:Integer}
    d = gcd(r.num, r.den)
    SimpleRatio(div(r.num, d), div(r.den, d))
end

coprime(n) = n

function getrec(collection, key, default)
    get(collection, key, default)
end

function getrec(collection, key, args...)
    if haskey(collection, key)
        getrec(collection[key], args...)
    else
        args[end]
    end
end

function parserational(str)
    m = match(r"(\d+)/(\d+)", str)
    parse(m[1]) // parse(m[2])
end

# Iterators
# =========

## addeltype
## -----------

struct TypedIterator{I,T}
    inner :: I
end

witheltype(itr::I, T::Type) where I = TypedIterator{I,T}(itr)

iterate(itr::TypedIterator) = start(itr.inner)
iterate(itr::TypedIterator, st) = iterate(itr.inner, st)

IteratorEltype(::Type{TypedIterator}) = Base.HasEltype()
eltype(::Type{TypedIterator{I,T}}) where {I,T} = T

IteratorSize(itr::Type{TypedIterator{I,T}}) where {I,T} = iteratorsize(I)
length(itr::TypedIterator) = length(itr.inner)
size(itr::TypedIterator) = size(itr.inner)
size(itr::TypedIterator, dim...) = size(itr.inner, dim...)

## takewhile
## ---------

struct TakeWhileItr{T}
    itr :: T
    f :: Function
end

takewhile(f, itr) = TakeWhileItr(itr, f)

function iterate(twi::TakeWhileItr{T}, s...) where T
    val, nxt = @ifsomething iterate(twi.itr, s...)
    if twi.f(val)
        val, nxt
    end
end

IteratorEltype(::Type{TakeWhileItr{T}}) where T = iteratoreltype(T)

eltype(::Type{TakeWhileItr{T}}) where T = eltype(T)

IteratorSize(::Type{TakeWhileItr{T}}) where T = Base.SizeUnknown()

IteratorSize(::TakeWhileItr{T}) where T = Base.SizeUnknown()

# list operations
# ===============

## dropwhile

dropwhile(f, lst::EmptyList) = lst
function dropwhile(f, lst::PersistentList)
    while !isempty(lst) && f(head(lst))
        lst = tail(lst)
    end
    lst
end

end # module
