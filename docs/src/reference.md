# DigitalMusicology.jl

All exported names of the submodules that are listed here are reexported by `DigitalMusicology`.

## Pitches

Pitch can be represented in many different ways, for example, as frequencies, piano keys,
or the vertical position and the accedentals of written notes (spelled pitches).
Representations of pitches are collected in the submodule `Pitches`.
They are subtypes of the abstract `Pitch` type, support additive operations (`+`, `-`, `zero`),
and have an order (via `isless`).

Currently, only [MIDI](https://en.wikipedia.org/wiki/MIDI) pitches are implemented,
other representations will follow.


```@autodocs
Modules = [DigitalMusicology.Pitches]
Private = false
```

## Pitch Operations

Common operations on pitches and pitch-based structures.

```@autodocs
Modules = [DigitalMusicology.PitchOps]
Private = false
```

## [Pitch Collections](@id Pitch-Collections)

The module `PitchCollections` provides structurs build out of pitches and pitch classes.

```@autodocs
Modules = [DigitalMusicology.PitchCollections]
Private = false
```

## Notes

Notes are pitches with some kind of time information.
In its most simple form, a note consists of a pitch, an onset, and an offset.
In a more complicated context, time information might be represented differently.

```@autodocs
Modules = [DigitalMusicology.Notes]
Private = false
```

## Timing

The timing interface provides methods for querying information on timed objects.
A timed object may have an `onset`, an `offset`, and a `duration`.
As not every object has all of these properties,
`hasonset`, `hasoffset`, and `hasduration` should be used to indicate,
which pieces of information are available.
It is usually sufficient to define either `onset` and `offset` or `onset` and `duration`.

Furthermore, simple distance measures based on time are provided as `skipcost` and `onsetcost`.

```@autodocs
Modules = [DigitalMusicology.Timed]
Private = false
```

## Meter

Time signatures and Meter

```@autodocs
Modules = [DigitalMusicology.Meter]
```

## Slices

A piece of music might be represented as a list of slices by "cutting" it
whenever a note starts or ends.
A slice then has and onset, an offset, and a duration,
and contains a [collection of pitches](@ref Pitch-Collections)
that sound during the slice.

```@autodocs
Modules = [DigitalMusicology.Slices]
Private = false
```

## Events

General containers for events.
Events can be either based on time points or on time intervals.
Both types of intervals 

```@autodocs
Modules = [DigitalMusicology.Events]
Private = false
```

## Grams

Functions for generating n-grams, scapes, and skipgrams on streams.

In order to generate classical skipgrams, use [`indexskipgrams`](@ref).
[`skipgrams`](@ref) provides more general variant,
which allows a custom cost function and
a compatibility predicate over pairs of input tokens.
While the cost function generalizes the `amount of skip` from indices to arbitrary costs,
the compatibility predicate allows, for example, to ensure non-overlapping skipgrams
on overlapping input or early filtering of undesired skipgrams.

```@autodocs
Modules = [DigitalMusicology.Grams]
Private = false
```

## Viewing

Helpers for viewing music.

Midi files in a corpus can be viewed using [MuseScore](https://musescore.org/).
(This function will probably be moved to the corpora package.)

In Jupyter notebooks, [Humdrum](http://www.humdrum.org/) `**kern` strings can be viewed
(and played) using [Verovio](http://www.verovio.org/)
(in fact, the branch of Verovio that is used in the
[Verovio HumDrum Viewer](http://doc.verovio.humdrum.org/)).
Therefore, a musical structure can be visualized by translating it to a
[`HumDrumString`](@ref).

For example, the Humdrum string

```
**kern	**kern
*clefF4	*clefG2
*k[f#]	*k[f#]
*M4/4	*M4/4
=-	=-
8GL	8ddL
8AJ	8ccJ
16BLL	2.b;
16A	.
16G	.
16F#JJ	.
2G;	.
==	==
*-	*-
```

will be displayed as

![verovio svg](assets/vhv_example.svg)

As Verovio can display other formats than Humdrum,
corresponding types might be added in the future.

```@autodocs
Modules = [DigitalMusicology.External]
Private = false
```

## Corpora

Musical corpora contain pieces in various file formats and additional metadata.
As different corpora have a different internal layout, DM.jl provides an interface
that can be implemented for each type of corups that is used.
A single piece is identified by a piece id and can be loaded in different representations
that may contain different pieces of information about the piece,
e.g. as a note list from MIDI files or as Metadata from JSON or CSV files.
The implementation of a corpus must provide methods to list all possible piece ids.
Piece ids may be organized hierarchically,
e.g., in order to reflect the directory structure of the corpus.

Each corpus implements its own subtype of `Corpus`,
on which the implementation of the general interface dispatches.
For convenience, a currently active corpus can be set using `setcorpus`.
Corpus interface methods called without the corpus argument default to this
currently active corpus.
Each corpus implementation should provide a convenience function `useX` that creates
a corpus object and sets it as active.

```@autodocs
Modules = [DigitalMusicology.Corpora]
Private = false
```

### Large Archive Corpus

A "LAC" contains an index CSV file and a set of toplevel directories
according to different representations of the content of the corpus.
Each of these "type"-directories contains the same folder hierarchy below it,
including the names of the actual data files, except the file extension.
The id of a piece is therefore its path in this common substructure,
separated with `/` and ending in the filename without extension.
The actual file of a certain type can then be retrieved from the id
by prepending the name of the type-directory and appending the appropriate file extension.

```@autodocs
Modules = [DigitalMusicology.Corpora.LAC]
Private = false
```

### Kern Corpus (WIP)

A Kern corpus provides access to the Humdrum `**kern` corpora provided by Craig Sapp
like the [Mozart Piano Sonatas](https://github.com/craigsapp/mozart-piano-sonatas).
Note that running some extra commands like `make midi-norep` might be required first.

Currently, the files can only be read from MIDI, not directly from Humdrum,
but this is being worked on.

```@autodocs
Modules = [DigitalMusicology.Corpora.Kern]
Private = false
```
