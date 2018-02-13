module Helpers

import Base: iteratoreltype, start, next, done, iteratorsize, eltype, length, size

export witheltype

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

end # module
