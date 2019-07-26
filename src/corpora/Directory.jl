module Directory

import ...Corpora: supportedforms, allpieces, dirs, pieces, piecepath, findpieces, ls, topdir, _getpiece
using ....DigitalMusicology
using ...Corpora: Corpus

using DataFrames: eachrow
using LightXML: parse_file

export dircrp, usedir

struct DirCorpus <: Corpus
    datadir :: String
    ids :: Vector{String}
end

const KNOWN_EXTENSIONS = Set([
    ".xml",
    ".musicxml"
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

function _getpiece(id, ::Val{:all}, ::Val{:musicxml}, crp::DirCorpus; keepids=true, unfold=true)
    fn = getpiece(id, :file, :musicxml, crp)
    if keepids
        readmusicxml(fn, unfold=unfold)
    else
        readmusicxml(loadwithids(fn), unfold=unfold)
    end
end

function _getpiece(id, ::Val{:timesigs}, ::Val{:musicxml}, crp::DirCorpus; unfold=true)
    if unfold
        @warn "unfolding for time signatures is not implemented yet!"
    end
    getpiece(id, :all, :musicxml, crp; keepids=true, unfold=unfold).timesigs
end

function _getpiece(id, ::Val{:notes}, ::Val{:musicxml}, crp::DirCorpus; keepids=true, type=:df, unfold=true)
    notes = getpiece(id, :all, :musicxml, crp; keepids=keepids, unfold=unfold).notes
    if type == :df
        notes
    elseif type == :notes
        [TimedNote(spelledp(n[:dia], n[:chrom]), n[:onset], n[:offset], n[:id])
         for n in eachrow(notes)]
    end
end

function _getpiece(id, ::Val{:xml}, ::Val{:musicxml}, crp::DirCorpus; keepids=true, type=:object)
    fn = getpiece(id, :file, :musicxml, crp)
    
    if keepids
        xml = parse_file(fn)
    else
        xml = loadwithids(fn)
    end

    if type == :object
        xml
    elseif type == :string
        string(xml)
    end
end

end # module
