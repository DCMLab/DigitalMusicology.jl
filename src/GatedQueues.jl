module GatedQueues

using DigitalMusicology.Helpers: takewhile, dropwhile
using FunctionalCollections
import Base: merge, isempty

export GatedQueue, gatedq, update_entry, release

struct GatedQueue{K,V}
    entries :: FunctionalCollections.AbstractList{Tuple{K,V}}
end

gatedq(K::Type, V::Type) = GatedQueue(plist{Tuple{K,V}}([]))

isempty(q::GatedQueue) = isempty(q.entries)

"""
    update_entry(f, q, key, default)

Applies `f` to the value of `key` in `q` or to `default`, if `key` is not present. 
"""
function update_entry(f::Function, q::GatedQueue{K,V}, key::K, default::V) where {K,V}
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

function merge(combine::Function, q1::GatedQueue{K,V}, q2::GatedQueue{K,V}) where {K,V}
    merge_rec(lst1, ::EmptyList) = lst1
    
    merge_rec(::EmptyList, lst2::PersistentList) = lst2
    
    merge_rec(lst1::plist, lst2::plist) = begin
        h1 = head(lst1)
        h2 = head(lst2)
        if h1[1] < h2[1]
            cons(h1, merge_rec(tail(lst1), lst2))
        elseif h2[1] < h1[1]
            cons(h2, merge_rec(lst1, tail(lst2)))
        else # h1[1] == h2[1]
            cons((h1[1], combine(h1[2], h2[2])),
                 merge_rec(tail(lst1), tail(lst2)))
        end
    end
    GatedQueue{K,V}(merge_rec(q1.entries, q2.entries))
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
    (released, newq)
end

end #module
