module Corpora

using IterTools: imap, chain
using Reexport.@reexport

export Corpus, NoCorpus
export get_corpus, set_corpus
export supported_forms, all_pieces, top_dir, dirs, pieces, ls
export piece_path, get_piece, get_pieces, _get_piece

# Corpus and current corpus
# =========================

abstract type Corpus end

struct NoCorpus <: Corpus end
==(c1::NoCorpus, c2::NoCorpus) = true

global corpus = NoCorpus()

"Get the currently set corpus.
Throws an error, if the corpus is not set."
function get_corpus()
    global corpus
    if isa(corpus, NoCorpus)
        error("Please set a default corpus with set_corpus(corpus).")
    else
        corpus
    end
end

"Set the current corpus."
function set_corpus(crp::Corpus)
    global corpus
    corpus = crp
end

"Reset the current corpus to `NoCorpus()`."
function unset_corpus()
    global corpus
    corpus = NoCorpus()
end

# Corpus Interface
# ================

"""
    supported_forms([corpus])

Returns a list of symbols that can be passed to the `form` parameter
in piece loading functions for the given corpus.
"""
function supported_forms end
supported_forms() = supported_forms(get_corpus())

## Piece IDs and Directories
## -------------------------

"""
    all_pieces([corpus])

Returns all piece ids in `corpus`.

    all_pieces(dir, [corpus])

Returns all piece ids in and below `dir`.
"""
function all_pieces end
all_pieces() = all_pieces(get_corpus())
all_pieces(dir) = all_pieces(dir, get_corpus())
all_pieces(c::Corpus) = all_pieces(top_dir(c), c)

"""
    top_dir([corpus])

Returns the main piece directory of `corpus`.
"""
function top_dir end
top_dir() = top_dir(get_corpus())
top_dir(::Corpus) = "./"

"""
    dirs([corpus])

Returns all top-level piece directories in `corpus`.

    dirs(dir, [corpus])

Returns all direct subdirectories of `dir`.
"""
function dirs end
dirs() = dirs(get_corpus())
dirs(dir) = dirs(dir, get_corpus())
dirs(c::Corpus) = dirs(top_dir(c), c)

"""
    pieces(dir, [corpus])

Returns the piece ids in `dir`.
"""
function pieces end
pieces(dir) = pieces(dir, get_corpus())

"""
    ls([corpus])

Returns all top-level pieces and directories in `corpus` at once.

    ls(dir, [corpus])

Returns all subdirectories and pieces in `dir` at once.
"""
function ls end
ls() = ls(get_corpus())
ls(dir) = ls(dir, get_corpus())
ls(c::Corpus) = ls(top_dir(c), c)
ls(dir, c::Corpus) = collect(chain(dirs(dir, c), pieces(dir, c)))

## Loading Pieces
## --------------

"""
    piece_path(id, cat, ext, [corpus])

Returns the full path to the file of piece `id`
in category `cat` with extension `ext` in `corpus`.
"""
function piece_path end
piece_path(id, cat, ext) = piece_path(id, cat, ext, get_corpus())

"""
    get_piece(id, form, [corpus])

Loads a piece in some representation.
Piece ids are strings, but their exact format depends on the given corpus.

Forms are identified by keywords, e.g.
* `:slices`
* `:slices_df`
* `:notes`
but the supported keywords depend on the corpus.
"""
get_piece(id, form::Symbol, corpus = get_corpus()) =
    _get_piece(id, Val{form}(), corpus)

"""
    get_pieces(ids, form, [data_dir])

Like `get_piece` but takes multiple ids and returns
an iterator over the resulting pieces.
"""
get_pieces(ids, form, corpus = get_corpus()) =
    imap(id -> get_piece(id, form, corpus), ids)

"""
_get_piece(id, Val{form}(), corpus)

This function is responsible for actually loading a piece.
New corpus implementations should implement this method instead of `get_piece`,
which is called by the user.
"""
function _get_piece end

# load submodules
# ---------------


include("corpora/LAC.jl")
@reexport using .LAC

end # module
