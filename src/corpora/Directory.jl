module Directory

import ...Corpora: supportedforms, allpieces, dirs, pieces, piecepath, findpieces, ls, topdir, _getpiece
using ....DigitalMusicology
using ...Corpora: Corpus

using DataFrames: eachrow

export dircrp, usedir

struct DirCorpus <: Corpus
    datadir :: String
    ids :: Vector{String}
end

const KNOWN_EXTENSIONS = Set([
    ".xml"
])

function dircrp(dir::String)
    if !isdir(dir); error("not a valid directory: $dir") end
    ids = [fn[1] for fn in map(splitext ∘ basename, readdir(dir)) if fn[2] ∈ KNOWN_EXTENSIONS]
    DirCorpus(dir, ids)
end

usedir(dir::String) = setcorpus(dircrp(dir))

allpieces(d::DirCorpus) = d.ids

allpieces(dir, d::DirCorpus) =
    if dir == "./"; d.ids else String[] end

dirs(dir, d::DirCorpus) = String[]

pieces(dir, d::DirCorpus) = allpieces(dir, d)

piecepath(id, cat, ext, d::DirCorpus) = joinpath(d.datadir, id * ext)

# piece accessors
# ---------------

function _getpiece(id, ::Val{:file}, ::Val{:musicxml}, crp::DirCorpus)
    fn = piecepath(id, nothing, ".xml", crp)
    if !isfile(fn)
        fn = piecepath(id, nothing, ".musicxml", crp)
    end
    if isfile(fn)
        fn
    else
        nothing
    end
end

function _getpiece(id, ::Val{:all}, ::Val{:musicxml}, crp::DirCorpus; keepids=true)
    fn = getpiece(id, :file, :musicxml, crp)
    if keepids
        readmusicxml(fn)
    else
        readmusicxml(loadwithids(fn))
    end
end

_getpiece(id, ::Val{:timesigs}, ::Val{:musicxml}, crp::DirCorpus) =
    getpiece(id, :all, :musicxml, crp; keepids=true).timesigs

# function _getpiece(id, ::Val{notes}, ::Val{:musicxml}, crp::DirCorpus; keepids=true, type=:df)
#     notes = getpiece(id, :all, :musicxml, crp; keepids).notes
#     if type == :df
#         notes
#     elseif type == :notes
#         [TimedNote(SpelledPitch(n[:
# end


end # module
