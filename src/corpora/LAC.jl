module LAC

importall DigitalMusicology.Corpora
using DigitalMusicology

using CSV: read
using DataFrames: DataFrame, GroupedDataFrame, groupby
using IterTools: imap, chain
using Base.Iterators: flatten
using Query
using Missings: ismissing, missing, Missing

export lac, use_lac, meta, year_bins

struct LACCorpus <: Corpus
    data_dir :: String
    # piece_ids :: Vector{String}
    subdirs :: Dict{String}
    dirpieces :: Dict{String}
    meta :: DataFrame
end

# should this point to .tsv? -> adapt `read` in `lac`
const meta_file = "midi-metadata.csv"

data_dir(crp::LACCorpus) = crp.data_dir

function lac(dir :: String)
    meta = read(joinpath(dir, meta_file))
    meta[:id] = map(first∘splitext, meta[:file_name])

    subdirs = Dict{String, Set{String}}()
    dirpieces = Dict{String, Set{String}}()
    for id in meta[:id]
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

    LACCorpus(dir, subdirs, dirpieces, meta)
end

use_lac(dir :: String) = set_corpus(lac(dir))

# piece ids and directories
# -------------------------

all_pieces(l::LACCorpus) = l.meta[:id]

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

piece_path(id::String, cat::String, ext::String, crp::LACCorpus) =
    joinpath(data_dir(crp), cat, id * ext)

"""
    meta([LACCorpus])

Returns the corpus' meta-dataframe.
"""
meta(c::LACCorpus = get_corpus()) = c.meta

# pieces_where(colum::Symbol, value, c::LACCorpus = get_corpus()) =
#     @from row in meta(c) begin
#         @where i[column] == value
#         @select i.id
#     end

function parseYear(str) :: Union{Missing,Int}
    m = match(r"\d\d\d\d", str)
    if m == nothing
        missing
    else
        parse(m.match)
    end
end

"""
    year_bins(timespan [, reference=0 [, corpus]])

Returns piece ids in a list of bins as named tuples
`(onset, offset, bin, ids)`.
The bins are `timespan` years wide and start at `reference`.
Only pieces with a readable `composition_year` metadata entry
are returned.
The year is read from the `composition_year` column by taking the first
sequence of 4 digits in each row.
"""
function year_bins(timespan::Int, reference::Int = 0, c::LACCorpus = get_corpus())
    df = meta(c)
    #miny = minimum(df[:composition_year])
    #maxy = maximum(df[:composition_year])
    #year_to_bin(year) = fld(year - reference, timespan)
    bins = @from row in meta(c) begin
        @where row.composition_year.hasvalue
        @let year = parseYear(row.composition_year.value)
        @where !ismissing(year)
        @group row.id by fld(year - reference, timespan) into g
        @select {onset=g.key * timespan + reference,
                 offset=(g.key+1)*timespan + reference - 1,
                 bin=g.key,
                 ids=g}
        @collect
    end
    sort(bins, by=(p -> p[3]))
end


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
    filter(r -> r[:id] == id, corpus.meta)[1, :]

end #module
