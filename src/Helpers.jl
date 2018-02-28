module Helpers

import Base: iteratoreltype, start, next, done, iteratorsize, eltype, length, size
using FunctionalCollections
using Ratios

export witheltype, takewhile, dropwhile, coprime

# Misc
# ====

function coprime(r::SimpleRatio{T}) where {T<:Integer}
    d = gcd(r.num, r.den)
    SimpleRatio(div(r.num, d), div(r.den, d))
end

coprime(n) = n

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

eltype(twi::TakeWhileItr) = eltype(twi.itr)

iteratorsize(::Type{TakeWhileItr{T}}) where T = Base.SizeUnknown()

iteratorsize(::TakeWhileItr{T}) where T = Base.SizeUnknown()

# list operations
# ===============

## dropwhile

dropwhile(f, lst::EmptyList) = lst
dropwhile(f, lst::PersistentList) =
    if f(head(lst))
        dropwhile(f, tail(lst))
    else
        lst
    end

end # module
