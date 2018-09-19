module MidiTools2

using DigitalMusicology
using Statistics
using Ratios
using HDF5
using Base.Iterators
using Plots

export mobility,melaccent,keysom,keysomlabels,duraccent,keyN, keyx,keyy,somw
"""
    mobility(notes)

Mobility describes why melodies change direction after large skips
by simply observing that they would otherwise run out of the
comfortable melodic range. It uses lag-one autocorrelation between
successive pitch heights (Hippel, 2000).
"""
function mobility(notes)
    if iterate(notes) == nothing
        return []
    end
    i = 2
    p1 = Float64[]
    p2 = zeros(1)
    mob = Float64[]
    y = []
    for n in notesequence(notes,2)
        m = mean(map(e->(pitch(e)).pitch,take(notes,i-1)))
        append!(p1, (pitch(n[1])).pitch - m)
        append!(p2,(pitch(n[1])).pitch - m)
        z = [p1 ;  [(pitch(n[1])).pitch - m]]
        c = cor(p2 , z)
        if isnan(c)
            push!(mob,0.0)
        else
            push!(mob, c)
        end
        push!(y,mob[i-1]*((pitch(n[2])).pitch-m))
        i += 1
    end
    y[2] = 0
    y = vcat([0],y)
    return map(abs,y)
end


"""
    melaccent(notes, ivcomp = (e1,e2)-> (e1 > e2) ? 1 : ((e1 == e2) ? 0 : -1 ))

Computes melodic salience according to Thomassen's model
"""
function melaccent(notes, ivcomp = (e1,e2)-> (e1 > e2) ? 1 : ((e1 == e2) ? 0 : -1 ))
    if iterate(notes) == nothing
        return []
    end
    d = []
    i = 1
    i1 = 0.0
    i2 = 0.0
    me12 = []
    for ns in notesequence(notes,3)
        motion1 = ivcomp(pitch(ns[2]),pitch(ns[1]))
        motion2 = ivcomp(pitch(ns[3]) ,pitch(ns[2]))

        if motion1==0 && motion2==0
            (i1,i2) = (0.00001, 0.0)
        elseif motion1 !=0 && motion2==0
            (i1,i2) = (1, 0.0)
        elseif motion1==0 && motion2 !=0
            (i1,i2) = (0.00001, 1)
        elseif motion1>0 && motion2<0
            (i1,i2) = (0.83,0.17)
        elseif motion1<0 && motion2>0
            (i1,i2) = (0.71, 0.29)
        elseif motion1>0 && motion2>0
            (i1,i2) = (0.33, 0.67)
        elseif motion1<0 && motion2<0
            (i1,i2) = (0.5, 0.5)
        end

        if length(d) == 0
            push!(d,i1,i2)
        else
            d[i] = i1
            push!(d,i2)
        end

        push!(me12, (d[i],d[i+1]))
        i += 1
    end
    p2 = zeros(Float64,length(d) + 1)
    p2[1] = 1
    p2[2] = (me12[1])[1]
    for k = 3 : length(d)
        tmp1 = (me12[k-2])[2] != 0 ? (me12[k-2])[2] : 1
        tmp2 = (me12[k-1])[1] != 0 ? (me12[k-1])[1] : 1
        p2[k] = tmp1 * tmp2
        println(tmp1)
        println(tmp2)
    end

    p2[length(d) + 1] = (me12[end])[2]
    return p2
end

"""
    keysom(notes)
Creates a pseudocolor map of the pitch class distribution
of the notes projected onto a self-organizing map trained with the
Krumhansl-Kessler profiles.
"""
function keysom(notes)
    if iterate(notes) == nothing
        return []
    end
    z = zeros(24,36)
    #somw = read(matopen("keysomdata.mat"),"somw")
    #mat = somw()
    pcd = pcdist1(notes,duraccent)

    ts = mean(collect(values(pcd)))
    for i in keys(pcd)
        pcd[i] = pcd[i]-ts
    end
    tm = sqrt(sum(map(e->e^2,collect(values(pcd)))))
    for i in keys(pcd)
        pcd[i] = pcd[i]/tm
    end
    for k = 1:36
        for l = 1:24
            s = 0.0
            for m = 1:12
                #s += get!(pcd,midi(m-1),0)*mat[m,k,l]
                s += get!(pcd,midi(m-1),0)*(h5read("data.h5","datasom",(m,k,l)))[1]
            end
            z[l,k] = s
        end
    end
    #matrix is upside down, don't know why
    rz = zeros(24,36)
    for i = 1:24,j = 1:36  rz[i,j] = z[25-i,j] end

    heatmap(rz)
    annotate!(keysomlabels())
end
"""
    keysomlabels()

return the position in the 24x36 keysom matrix of the tonalities
"""
function keysomlabels()
    #keyN = read(matopen("keysomdata.mat"),"keyN")
    #keyx = read(matopen("keysomdata.mat"),"keyx")
    #keyy = read(matopen("keysomdata.mat"),"keyy")
    d = Array{Tuple{Int64,Int64,String}}(undef,24)
    x = keyx()
    y = keyy()
    N = keyN()
    for i = 1:24
        d[i] = (x[i],y[i],N[i])
    end
    return d
end

"""
    duraccent(note,tau :: Float64 = 0.5, accentIndex :: Float64 = 2.0)

return the duration of the note corrected by the Parncutt durational accent model
"""
function duraccent(note,tau :: Float64 = 0.5, accentIndex :: Float64 = 2.0)
  return (1-exp(-duration(note)/tau))^accentIndex
end


#extracted variables from keysomdata.mat
function keyN()
    vkeyN = ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B", "c", "c#", "d", "d#", "e", "f", "f#", "g", "ab", "a", "bb", "b"]
    return vkeyN
end
function keyx()
    vkeyx = [18.0; 33.0; 12.0; 27.0; 6.0; 21.0; 36.0; 15.0; 30.0; 9.0; 24.0; 3.0; 23.0; 2.0; 17.0; 32.0; 11.0; 26.0; 5.0; 20.0; 35.0; 14.0; 29.0; 8.0]
    return vkeyx
end
function keyy()
    vkeyy = [13.0; 19.0; 1.0; 7.0; 13.0; 19.0; 1.0; 7.0; 13.0; 19.0; 1.0; 7.0; 11.0; 17.0; 23.0; 5.0; 11.0; 17.0; 23.0; 5.0; 11.0; 17.0; 23.0; 5.0]
    return vkeyy
end

function somw()
    vsom = zeros(12,36,24)
    return vsom
end

end #module
