module LAC

import DigitalMusicology.Corpora: supportedforms, allpieces, topdir, dirs, pieces, ls, findpieces, _getpiece
using DigitalMusicology
using DigitalMusicology.Corpora: Corpus

using CSV: read
using DataFrames: DataFrame, GroupedDataFrame, groupby, eachrow
using IterTools: imap
using Base.Iterators: flatten
# using Query
# using Missings: ismissing, missing, Missing

using DigitalMusicology.Helpers: witheltype

export lac, uselac, meta, yearbins

struct LACCorpus <: Corpus
    datadir :: String
    # pieceids :: Vector{String}
    subdirs :: Dict{String}
    dirpieces :: Dict{String}
    meta :: DataFrame
end

# should this point to .tsv? -> adapt `read` in `lac`
const metafile = "midi-metadata.csv"

datadir(crp::LACCorpus) = crp.datadir

function lac(dir :: String)
    meta = read(joinpath(dir, metafile))
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

uselac(dir :: String) = setcorpus(lac(dir))

# piece ids and directories
# -------------------------

allpieces(l::LACCorpus) = l.meta[:id]

function allpieces(dir, l::LACCorpus)
    ds = dirs(dir)
    isempty(ds) ? pieces(dir) : flatten([pieces(dir), flatten(Set(allpieces(d) for d = ds))])
end

function dirs(dir, l::LACCorpus)
    pfx = dir == "./" ? "" : dir
    Set(pfx * d for d = get(l.subdirs, dir, Set{String}()))
end

function pieces(dir, l::LACCorpus)
    pfx = dir == "./" ? "" : dir
    Set(pfx * p for p = get(l.dirpieces, dir, Set{String}()))
end

piecepath(id::String, cat::String, ext::String, crp::LACCorpus) =
    joinpath(datadir(crp), cat, id * ext)

findpieces(searchstr::AbstractString, crp::LACCorpus) = findpieces(Regex(string(searchstr), "i"), crp)

# TODO: reenable once Query works again
# findpieces(searchstr::Regex, crp::LACCorpus) =
#     @from row in meta(crp) begin
#         @where occursin(searchstr, row[:id]) ||
#             occursin(searchstr, row[:composer]) ||
#             occursin(searchstr, get(row[:work_category], "")) ||
#             occursin(searchstr, row[:work_title]) ||
#             occursin(searchstr, get(row[:composition_year], "")) ||
#             occursin(searchstr, get(row[:musical_key], "")) ||
#             occursin(searchstr, get(row[:genre], ""))
#         @select row
#         @collect DataFrame
#     end

"""
    meta([crp::LACCorpus])

Returns the corpus' meta-dataframe.
"""
meta(c::LACCorpus = getcorpus()) = c.meta

# pieceswhere(colum::Symbol, value, c::LACCorpus = getcorpus()) =
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

# TODO: reenable once Query is fixed
# """
#     yearbins(timespan [, reference=0 [, corpus]])

# Returns piece ids in a list of bins as named tuples
# `(onset, offset, bin, ids)`.
# The bins are `timespan` years wide and start at `reference`.
# Only pieces with a readable `composition_year` metadata entry
# are returned.
# The year is read from the `composition_year` column by taking the first
# sequence of 4 digits in each row.
# """
# function yearbins(timespan::Int, reference::Int = 0, c::LACCorpus = getcorpus())
#     df = meta(c)
#     #miny = minimum(df[:composition_year])
#     #maxy = maximum(df[:composition_year])
#     #year_to_bin(year) = fld(year - reference, timespan)
#     bins = @from row in meta(c) begin
#         @where row.composition_year.hasvalue
#         @let year = parseYear(row.composition_year.value)
#         @where !ismissing(year)
#         @group row.id by fld(year - reference, timespan) into g
#         @select {onset=g.key * timespan + reference,
#                  offset=(g.key+1)*timespan + reference - 1,
#                  bin=g.key,
#                  ids=g}
#         @collect
#     end
#     sort(bins, by=(p -> p[3]))
# end


# helpers
# -------

function groups_to_slices(groups::GroupedDataFrame)
    mkslice(group)::Slice{Int, Vector{MidiPitch}} =
        Slice(group[:onset][1],
              group[:duration][1],
              midis(group[:pitch]))
    witheltype(imap(mkslice, groups), Slice{Int, Vector{MidiPitch}})
end

# piece accessors
# ---------------

# piece as a slice data frame
function _getpiece(id, ::Val{:slices_df}, crp::LACCorpus)
    fn = piecepath(id, "slices", ".tsv", crp)
    read(fn, delim='\t', nullable=false)
end

# piece as a Slice iterator
function _getpiece(id, ::Val{:slices}, corpus::LACCorpus)
    df = getpiece(id, :slices_df, corpus)
    groups = groupby(df, :onset)
    groups_to_slices(groups)
end

function _getpiece(id, ::Val{:notes}, crp::LACCorpus)
    fn = piecepath(id, "m", ".mid", crp)
    midifilenotes(fn)
end

function _getpiece(id, ::Val{:notes_secs}, crp::LACCorpus)
    df = getpiece(id, :notes, crp)
    [TimedNote(n[:pitch], n[:onset_secs], n[:offset_secs]) for n in eachrow(df)]
end

function _getpiece(id, ::Val{:notes_wholes}, crp::LACCorpus)
    df = getpiece(id, :notes, crp)
    [TimedNote(n[:pitch], n[:onset_wholes], n[:offset_wholes]) for n in eachrow(df)]
end

_getpiece(id, ::Val{:meta}, corpus::LACCorpus) =
    filter(r -> r[:id] == id, corpus.meta)[1, :]

end #module
