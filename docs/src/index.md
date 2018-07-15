# DigitalMusicology.jl

DigitalMusicology.jl provides a toolbox for analyzing musical structure.

## Introduction

As a library for computational analysis of musical structure,
DigitalMusicology.jl provides

* data structures for representing musical information
* basic transformations and general algorithms on these structures
* conversion between representations, where appropriate
* input and output functionality.

Instead of attempting to represent all possible musical information in a single complex format,
the philosophy of DM.jl is to provide data structures that

* contain the information that is needed for a specific task
* contain only the information that is available in the source data.

The first point allows to use simple representations for simple tasks.
For example, if an analytic question uses a bag of notes model
and the input pieces are only available as bags of notes,
there is no need to convert the pieces into a general representation (like MusicXML, MEI, Humdrum, etc.)
and then extract from this the relevant information.
Instead, the piece is directly transformed from the source representation
to the target representation.

The second point addresses the problem that a source file might not contain information
that could be represented in a general format.
A MIDI file, for example, has no knowledge about articulation.
This information might be inferred from other data,
like the velocity of a note or its duration compared to the beat,
but this is only a heuristic.
Using a general representation either needs to handle problem explicitely
or hides the knowledge about which information is given in the data,
and which is inferred by a heuristic or is filled by a default value.

In DM.jl, conversion between representations will not silently add information
that is not present in the source by default,
so converting from a poor to a rich format is not possible unless explicit
values or estimation rules are provided for the missing data.
For example, a spelled pitch can be converted to a midi pitch without problem,
as the mapping from spelled pitches to the piano keyboard is clear.
The reverse direction is not clear, as a single key can refer to several spelled
pitches, so a disambiguation rule must be provided
(e.g., always choose the C-major names for white keys and add a single sharp for black keys).

## Documentation

Take a look at the [reference](reference.md).

Tutorials and explanations will follow.
