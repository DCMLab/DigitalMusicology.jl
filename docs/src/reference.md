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

General containers for events

```@autodocs
Modules = [DigitalMusicology.Events]
Private = false
```

## Grams

Functions for generating n-grams, scapes, and skipgrams on streams.

In order to generate classical skipgrams, use [`skipgrams`](@ref).
[`skipgrams_itr`](@ref) provides more general variant,
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
