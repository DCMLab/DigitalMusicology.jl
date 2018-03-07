module GatedQueues

using DigitalMusicology.Helpers: takewhile, dropwhile
using FunctionalCollections
import Base: merge, isempty, values

export GatedQueue, gatedq, update, release, enqueue, reenqueue

struct GatedQueue{K,V}
    entries :: FunctionalCollections.AbstractList{Tuple{K,V}}
end

gatedq(K::Type, V::Type) = GatedQueue(plist{Tuple{K,V}}([]))

isempty(q::GatedQueue) = isempty(q.entries)

"""
    update_entry(f, q, key, default)

Applies `f` to the value of `key` in `q` or to `default`, if `key` is not present. 
"""
function update(f::Function, q::GatedQueue{K,V}, key::K, default::V) where {K,V}
    updt(lst::EmptyList) = plist([(key, f(default))])
    updt(lst::plist{Tuple{K,V}}) = begin
        (k, v) = head(lst)
        if k == key
            cons((k, f(v)), tail(lst))
        elseif k > key
            cons((key, f(default)), lst)
        else
            cons(head(lst), updt(tail(lst)))
        end
    end
    GatedQueue{K,V}(updt(q.entries))
end

enqueue(q::GatedQueue{K,V}, key::K, value::V) where {K,V} =
    update(identity, q, key, value)

reenqueue(q::GatedQueue{K,V}, key::K, value::V) where {K,V} =
    update(x->value, q, key, value)

function merge(combine::Function, q1::GatedQueue{K,V}, q2::GatedQueue{K,V}) where {K,V}
    mergerec(lst1, ::EmptyList) = lst1
    mergerec(::EmptyList, lst2::PersistentList) = lst2
    mergerec(lst1::plist, lst2::plist) = begin
        h1 = head(lst1)
        h2 = head(lst2)
        if h1[1] < h2[1]
            cons(h1, mergerec(tail(lst1), lst2))
        elseif h2[1] < h1[1]
            cons(h2, mergerec(lst1, tail(lst2)))
        else # h1[1] == h2[1]
            cons((h1[1], combine(h1[2], h2[2])),
                 mergerec(tail(lst1), tail(lst2)))
        end
    end
    GatedQueue{K,V}(mergerec(q1.entries, q2.entries))
end

"""
    release(q, gate) -> released, q'

Returns all values with a key < `gate`
and the queue without these entries.
"""
function release(q::GatedQueue{K,V}, gate::K) where {K, V}
    pred(x) = x[1] < gate
    newq = GatedQueue{K,V}(dropwhile(pred, q.entries))
    released = takewhile(pred, q.entries)
    (map(x->x[2], released), newq)
end

values(q::GatedQueue{K,V}) where {K,V} =
    [entry[2] for entry in q.entries]

end #module
