module Kern

importall DigitalMusicology.Corpora
using DigitalMusicology

using DataFrames: eachrow

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

    ids = map(fn -> fn[1:end-4], filter(fn -> ismatch(r".*\.krn", fn), readdir(kerndir)))
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

findpieces(searchstr::Regex, crp::KernCorpus) = filter(id -> ismatch(searchstr, id), crp.ids)

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

end # module
