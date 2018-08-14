module Corpora

using Base.Iterators: flatten
using IterTools: imap
using Reexport: @reexport

export Corpus, NoCorpus
export getcorpus, setcorpus, unsetcorpus
export supportedforms, allpieces, topdir, dirs, pieces, ls, findpieces
export piecepath, getpiece, getpieces, _getpiece

# Corpus and current corpus
# =========================

abstract type Corpus end

struct NoCorpus <: Corpus end

global corpus = NoCorpus()

"Get the currently set corpus.
Throws an error, if the corpus is not set."
function getcorpus()
    global corpus
    if isa(corpus, NoCorpus)
        error("Please set a default corpus with setcorpus(corpus).")
    else
        corpus
    end
end

"Set the current corpus."
function setcorpus(crp::Corpus)
    global corpus
    corpus = crp
end

"Reset the current corpus to `NoCorpus()`."
function unsetcorpus()
    global corpus
    corpus = NoCorpus()
end

# Corpus Interface
# ================

"""
    supportedforms([corpus])

Returns a list of symbols that can be passed to the `form` parameter
in piece loading functions for the given corpus.
"""
function supportedforms end
supportedforms() = supportedforms(getcorpus())

supportedforms(::NoCorpus) = []

## Piece IDs and Directories
## -------------------------

"""
    allpieces([corpus])

Returns all piece ids in `corpus`.

    allpieces(dir, [corpus])

Returns all piece ids in and below `dir`.
"""
function allpieces end
allpieces() = allpieces(getcorpus())
allpieces(dir) = allpieces(dir, getcorpus())
allpieces(c::Corpus) = allpieces(topdir(c), c)

"""
    topdir([corpus])

Returns the main piece directory of `corpus`.
"""
function topdir end
topdir() = topdir(getcorpus())
topdir(::Corpus) = "./"

"""
    dirs([corpus])

Returns all top-level piece directories in `corpus`.

    dirs(dir, [corpus])

Returns all direct subdirectories of `dir`.
"""
function dirs end
dirs() = dirs(getcorpus())
dirs(dir) = dirs(dir, getcorpus())
dirs(c::Corpus) = dirs(topdir(c), c)

"""
    pieces(dir, [corpus])

Returns the piece ids in `dir`.
"""
function pieces end
pieces(dir) = pieces(dir, getcorpus())

"""
    ls([corpus])

Returns all top-level pieces and directories in `corpus` at once.

    ls(dir, [corpus])

Returns all subdirectories and pieces in `dir` at once.
"""
function ls end
ls() = ls(getcorpus())
ls(dir) = ls(dir, getcorpus())
ls(c::Corpus) = ls(topdir(c), c)
ls(dir, c::Corpus) = collect(flatten([dirs(dir, c), pieces(dir, c)]))

"""
    findpieces(searchstring[, corpus])

Searches the corpus for pieces matching searchstring.
Returns a dataframe of matching rows.
"""
function findpieces end
findpieces(searchstr) = findpieces(searchstr, getcorpus())

## Loading Pieces
## --------------

"""
    piecepath(id, cat, ext, [corpus])

Returns the full path to the file of piece `id`
in category `cat` with extension `ext` in `corpus`.
"""
function piecepath end
piecepath(id, cat, ext) = piecepath(id, cat, ext, getcorpus())

"""
    getpiece(id, form, [corpus])

Loads a piece in some representation.
Piece ids are strings, but their exact format depends on the given corpus.

Forms are identified by keywords, e.g.
* `:slices`
* `:slices_df`
* `:notes`
but the supported keywords depend on the corpus.
"""
getpiece(id, form::Symbol, corpus = getcorpus()) =
    _getpiece(id, Val{form}(), corpus)

"""
    getpieces(ids, form, [datadir])

Like `getpiece` but takes multiple ids and returns
an iterator over the resulting pieces.
"""
getpieces(ids, form, corpus = getcorpus(); skipmissings=false) = begin
    pieces = imap(ids) do id
        try
            getpiece(id, form, corpus)
        catch
            missing
        end
    end
    
    skipmissings ? skipmissing(pieces) : pieces
end

"""
_getpiece(id, Val{form}(), corpus)

This function is responsible for actually loading a piece.
New corpus implementations should implement this method instead of `getpiece`,
which is called by the user.
"""
function _getpiece end

# load submodules
# ---------------

include("corpora/LAC.jl")
@reexport using .LAC

include("corpora/Kern.jl")
@reexport using .Kern

end # module
