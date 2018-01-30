module LAC

importall DigitalMusicology.Corpora
using DigitalMusicology

using CSV: read
using DataFrames: DataFrame, GroupedDataFrame, groupby
using IterTools: imap, chain
using Base.Iterators: flatten

export lac, use_lac

struct LACCorpus <: Corpus
    data_dir :: String
    piece_ids :: Vector{String}
    subdirs :: Dict{String}
    dirpieces :: Dict{String}
    meta :: DataFrame
end

# should this point to .tsv? -> adapt `read` in `lac`
const meta_file = "midi-metadata.csv"

data_dir(crp::LACCorpus) = crp.data_dir

function lac(dir :: String)
    meta = read(joinpath(dir, meta_file))
    ids = map(first∘splitext, meta[:file_name])

    subdirs = Dict{String, Set{String}}()
    dirpieces = Dict{String, Set{String}}()
    for id in ids
        parent = ""
        parts = split(id, ['/'])
        for part in parts[1:end-1]
            path = string(part, "/")
            subdirs[parent] = push!(get!(subdirs, parent, Set{String}()), path)
            parent = joinpath(parent, path)
        end
        push!(get!(dirpieces, parent, Set{String}()), parts[end])
    end
    subdirs["./"] = pop!(subdirs, "", Set{String}())
    dirpieces["./"] = pop!(dirpieces, "", Set{String}())

    LACCorpus(dir, ids, subdirs, dirpieces, meta)
end

use_lac(dir :: String) = set_corpus(lac(dir))

# piece ids and directories
# -------------------------

all_pieces(l::LACCorpus) = l.piece_ids

function all_pieces(dir, l::LACCorpus)
    ds = dirs(dir)
    isempty(ds) ? pieces(dir) : chain(pieces(dir), flatten(map(all_pieces, ds)))
end

function dirs(dir, l::LACCorpus)
    pfx = dir == "./" ? "" : dir
    map(d -> pfx * d, get(l.subdirs, dir, Set{String}()))
end

function pieces(dir, l::LACCorpus)
    pfx = dir == "./" ? "" : dir
    map(p -> pfx * p, get(l.dirpieces, dir, Set{String}()))
end

piece_path(id, cat, ext, crp) =
    joinpath(data_dir(crp), cat, id * ext)

# helpers
# -------

function groups_to_slices(groups::GroupedDataFrame)
    mk_slice(group)::Slice{Int, Vector{MidiPitch}} =
        Slice(group[:onset][1],
              group[:duration][1],
              midis(group[:pitch]))
    imap(mk_slice, groups)
end

# piece accessors
# ---------------

# piece as a slice data frame
function _get_piece(id, ::Val{:slices_df}, crp::LACCorpus)
    fn = piece_path(id, "slices", ".tsv", crp)
    read(fn, delim='\t', nullable=false)
end

# piece as a Slice iterator
function _get_piece(id, ::Val{:slices}, corpus::LACCorpus)
    df = get_piece(id, :slices_df, corpus)
    groups = groupby(df, :onset)
    groups_to_slices(groups)
end

_get_piece(id, ::Val{:meta}, corpus::LACCorpus) =
    filter(r -> r[:file_name] == id*".mid", corpus.meta)[1, :]

end #module
