module Helpers

import Base: iteratoreltype, start, next, done, iteratorsize, eltype, length, size
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

start(itr::TypedIterator) = start(itr.inner)
next(itr::TypedIterator, st) = next(itr.inner, st)
done(itr::TypedIterator, st) = done(itr.inner, st)

iteratoreltype(::Type{TypedIterator}) = Base.HasEltype()
eltype(::Type{TypedIterator{I,T}}) where {I,T} = T

iteratorsize(itr::Type{TypedIterator{I,T}}) where {I,T} = iteratorsize(I)
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

start(twi::TakeWhileItr) = start(twi.itr)

next(twi::TakeWhileItr, s) = next(twi.itr, s)

done(twi::TakeWhileItr, s) =
    done(twi.itr, s) || !twi.f(next(twi.itr, s)[1])

iteratoreltype(::Type{TakeWhileItr{T}}) where T = iteratoreltype(T)

eltype(::Type{TakeWhileItr{T}}) where T = eltype(T)

iteratorsize(::Type{TakeWhileItr{T}}) where T = Base.SizeUnknown()

iteratorsize(::TakeWhileItr{T}) where T = Base.SizeUnknown()

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
