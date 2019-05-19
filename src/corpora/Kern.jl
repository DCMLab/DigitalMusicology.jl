module Kern

import ...Corpora: supportedforms, allpieces, dirs, pieces, piecepath, findpieces, ls, topdir, _getpiece
using ....DigitalMusicology
using ...Corpora: Corpus
using ...Helpers: getrec, parserational

using DataFrames: eachrow
import JSON

export kerncrp, usekern

struct KernCorpus <: Corpus
    datadir :: String
    ids :: Vector{String}
end

"""
    kerncrp(dir)

Creates a new KernCorpus with data directory `dir`.
"""
function kerncrp(dir::String)
    kerndir = joinpath(dir, "kern")
    if !isdir(dir); error(string("no valid directory: ", dir)) end
    if !isdir(kerndir); error(string("no kern directory in ", dir)) end

    ids = map(fn -> fn[1:end-4], filter(fn -> occursin(r".*\.krn", fn), readdir(kerndir)))
    KernCorpus(dir, ids)
end

"""
    usekern(dir)

Creates a new KernCorpus and sets it as the default corpus.
"""
usekern(dir::String) = setcorpus(kerncrp(dir))

# piece ids and directories
# -------------------------

allpieces(k::KernCorpus) = k.ids

allpieces(dir, k::KernCorpus) =
    if dir == "./"
        k.ids
    else
        String[]
    end

dirs(dir, k::KernCorpus) = String[]

pieces(dir, k::KernCorpus) =
    if dir == "./"
        k.ids
    else
        String[]
    end

piecepath(id, cat, ext, crp::KernCorpus) =
    joinpath(crp.datadir, cat, id * ext)

findpieces(searchstr::AbstractString, crp::KernCorpus) = findpieces(Regex(string(searchstr), "i"), crp)

findpieces(searchstr::Regex, crp::KernCorpus) = filter(id -> occursin(searchstr, id), crp.ids)

function hasupbeat(id, crp=getcorpus())
    fn = piecepath(id, "kern", ".krn", crp)
    kernstr = read(fn, String)
    occursin(r"=1\t", kernstr)
end

# piece accessors
# ---------------

function _getpiece(id, ::Val{:notes}, crp::KernCorpus)
    fn = piecepath(id, "midi-norep", ".mid", crp)
    midifilenotes(fn)
end

function _getpiece(id, ::Val{:notes_secs}, crp::KernCorpus)
    df = getpiece(id, :notes, crp)
    [TimedNote(n[:pitch], n[:onset_secs], n[:offset_secs]) for n in eachrow(df)]
end

function _getpiece(id, ::Val{:notes_wholes}, crp::KernCorpus)
    df = getpiece(id, :notes, crp)
    [TimedNote(n[:pitch], n[:onset_wholes], n[:offset_wholes]) for n in eachrow(df)]
end

function _getpiece(id, ::Val{:timesigs}, crp::KernCorpus)
    fn = piecepath(id, "midi-norep", ".mid", crp)
    aux = getpiece(id, :aux, crp)
    upbeat = parserational(getrec(aux, "rhythmic", "upbeat", "0/1"))
    midifiletimesigs(fn, upbeat=upbeat)
end

function _getpiece(id, ::Val{:aux}, crp::KernCorpus)
    fn = piecepath(id, "aux", ".json", crp)
    if isfile(fn)
        JSON.parse(read(fn, String))
    else
        Dict{String,Any}()
    end
end

end # module
