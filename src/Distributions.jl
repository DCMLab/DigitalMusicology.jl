module Distributions

using DigitalMusicology

export dist, pcdist1,pcdist2,ivdist1,ivdist2,durdist1,durdist2

"""
    dist(data,feature,func, normalize :: Bool = true)

compute the distribution of the feature of a given data
"""
function dist(data,feature = e->e,func = e -> 1, normalize :: Bool = true)
    if iterate(data) == nothing
        return Dict()
    end
    d = Dict()
    for e in data
        f = feature(e)
        if !haskey(d,f)
            d[f] = func(e)
        else
            d[f] += func(e)
        end
    end
    sv = sum(values(d))
    println(sv)
    if sv == 0 || !normalize
        return d
    end
    for k in keys(d)
        d[k] = d[k]/sv
    end
    return d
end

"""
    pcdist1(notes,weight = e ->1,normalize :: Bool = true)

compute the pitch-class distribution of the given notes
"""
pcdist1(notes,weight = e ->1,normalize :: Bool = true) =  dist(notes,e->pc(pitch(e)),weight,normalize)


"""
    pcdist2(notes,weight = (e1,e2)-> 1,normalize :: Bool = true)

compute the  second order pitch-class distribution of the given notes
works only with monophonic input
"""
pcdist2(notes,weight = (e1,e2)-> 1,normalize :: Bool = true) = dist(notesequence(notes,2),e->(pc(pitch(e[1])),pc(pitch(e[2]))),e->weight(e[1],e[2]),normalize)


"""
    durdist1(notes, weight = e->1,normalize :: Bool = true)

compute the duration distribution of the given notes
"""
durdist1(notes, weight = e->1,normalize :: Bool = true) = dist(notes,duration,weight,normalize)


"""
    durdist2(notes,weight = (e1,e2)-> 1,normalize :: Bool = true)

compute the second order duration distribution of the given notes
works only with monophonic input
"""
durdist2(notes,weight = (e1,e2)-> 1,normalize :: Bool = true) = dist(notesequence(notes,2),e->(duration(e[1]),duration(e[2])),e->weight(e[1],e[2]),normalize)


"""
    ivdist1(notes,weight = (e1,e2)->1,normalize :: Bool = true)

compute the interval distribution of the given notes
"""
ivdist1(notes,weight = (e1,e2)->1,normalize :: Bool = true) = dist(notesequence(notes,2),e->pitch(e[2])-pitch(e[1]),e-> weight(e[1],e[2]),normalize)


"""
    ivdist2(notes, weight = (e1,e2,e3)->1,normalize :: Bool = true)

compute the second order interval distribution of the given notes
works only with monophonic input
"""
ivdist2(notes, weight = (e1,e2,e3)->1,normalize :: Bool = true) = dist(notesequence(notes,3),e->(pitch(e[2])-pitch(e[1]),pitch(e[3])-pitch(e[2])),e->weight(e[1],e[2],e[3]),normalize)

end
