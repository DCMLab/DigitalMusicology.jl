module Contour

using DigitalMusicology

export melcontour, acorr, znnnotes

"""
    melcontour(notes, res,func)

return an array representing the melodic contour (computed the same way as the MidiToolBox),
'func' is the function of conversion of pitches to real number.
func return value must be Float64
"""
function melcontour(notes, res,func)
    if iterate(notes) == nothing
        return []
    end
    next = iterate(notes)
    acc = Array{Float64,1}(undef,0)
    return rcontour(acc,next[1],next[2],notes,onset(next[1]),res,func)

end

function rcontour(acc,note,state,notes,cur,res,func)

    next = iterate(notes,state)
    ncur = cur
    if  next == nothing
        while ncur <= offset(note)
            push!(acc,func(note))
            ncur += res
        end
        return acc
    else
        if onset(next[1]) <= cur
            rcontour(acc,next[1],next[2],notes,cur,res,func)
        else

            while(ncur < onset(next[1]))
                push!(acc,func(note))
                ncur += res
            end
            rcontour(acc,next[1],next[2],notes,ncur,res,func)
        end
    end
end

"""
    acorr(notes,res,func,pairlag :: Bool = false)

return an array representing the autocorrelation of the given notes.
The Array starts with the zero-lag value.If pairlag is true,
values are paired with their corresponding lags
"""
function acorr(notes,res,func,pairlag :: Bool = false)
    if iterate(notes) == nothing
        return []
    end
    c = melcontour(notes,res,func)
    if pairlag
        return collect(zip(countfrom(0,res),autocor(c,collect(0:length(c)-1))))
    else
        return autocor(c,collect(0:length(c)-1))
    end
end



"""
    znnotes(notes,feature)

return an iterator over a zero-normalized feature of the notes
the type of the feature of the note must be compatible with mean() and stdm()
"""
function znnotes(notes,feature)
    m = mean(map(feature,notes))
    sd = stdm(map(feature,notes),m)
    return map(e->(feature(e)-m)/sd,notes)
end

end # module
