var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Introduction",
    "title": "Introduction",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#DigitalMusicology.jl-1",
    "page": "Introduction",
    "title": "DigitalMusicology.jl",
    "category": "section",
    "text": "DigitalMusicology.jl provides a toolbox for analyzing musical structure."
},

{
    "location": "index.html#Introduction-1",
    "page": "Introduction",
    "title": "Introduction",
    "category": "section",
    "text": "As a library for computational analysis of musical structure, DigitalMusicology.jl providesdata structures for representing musical information\nbasic transformations and general algorithms on these structures\nconversion between representations, where appropriate\ninput and output functionality.Instead of attempting to represent all possible musical information in a single complex format, the philosophy of DM.jl is to provide data structures thatcontain the information that is needed for a specific task\ncontain only the information that is available in the source data.The first point allows to use simple representations for simple tasks. For example, if an analytic question uses a bag of notes model and the input pieces are only available as bags of notes, there is no need to convert the pieces into a general representation (like MusicXML, MEI, Humdrum, etc.) and then extract from this the relevant information. Instead, the piece is directly transformed from the source representation to the target representation.The second point addresses the problem that a source file might not contain information that could be represented in a general format. A MIDI file, for example, has no knowledge about articulation. This information might be inferred from other data, like the velocity of a note or its duration compared to the beat, but this is only a heuristic. Using a general representation either needs to handle problem explicitely or hides the knowledge about which information is given in the data, and which is inferred by a heuristic or is filled by a default value.In DM.jl, conversion between representations will not silently add information that is not present in the source by default, so converting from a poor to a rich format is not possible unless explicit values or estimation rules are provided for the missing data. For example, a spelled pitch can be converted to a midi pitch without problem, as the mapping from spelled pitches to the piano keyboard is clear. The reverse direction is not clear, as a single key can refer to several spelled pitches, so a disambiguation rule must be provided (e.g., always choose the C-major names for white keys and add a single sharp for black keys)."
},

{
    "location": "index.html#Documentation-1",
    "page": "Introduction",
    "title": "Documentation",
    "category": "section",
    "text": "Take a look at the reference.Tutorials and explanations will follow."
},

{
    "location": "reference.html#",
    "page": "Reference",
    "title": "Reference",
    "category": "page",
    "text": ""
},

{
    "location": "reference.html#DigitalMusicology.jl-1",
    "page": "Reference",
    "title": "DigitalMusicology.jl",
    "category": "section",
    "text": "All exported names of the submodules that are listed here are reexported by DigitalMusicology."
},

{
    "location": "reference.html#DigitalMusicology.Pitches.MidiPitch",
    "page": "Reference",
    "title": "DigitalMusicology.Pitches.MidiPitch",
    "category": "type",
    "text": "Pitches represented as chromatic integers. 60 is Middle C.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Pitches.Pitch",
    "page": "Reference",
    "title": "DigitalMusicology.Pitches.Pitch",
    "category": "type",
    "text": "Any pitch type should be a subtype of Pitch.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Pitches.midi-Tuple{Int64}",
    "page": "Reference",
    "title": "DigitalMusicology.Pitches.midi",
    "category": "method",
    "text": "Creates a MidiPitch from an integer.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Pitches.midis-Tuple{Any}",
    "page": "Reference",
    "title": "DigitalMusicology.Pitches.midis",
    "category": "method",
    "text": "Maps midi() over a collection of integers.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Pitches.@midi-Tuple{Any}",
    "page": "Reference",
    "title": "DigitalMusicology.Pitches.@midi",
    "category": "macro",
    "text": "@midi expr\n\nReplaces all Ints in expr with a call to midi(::Int). This allows the user to write integers where midi pitches are required. Does not work when expr contains integers that should not be converted.\n\n\n\n"
},

{
    "location": "reference.html#Pitches-1",
    "page": "Reference",
    "title": "Pitches",
    "category": "section",
    "text": "Pitch can be represented in many different ways, for example, as frequencies, piano keys, or the vertical position and the accedentals of written notes (spelled pitches). Representations of pitches are collected in the submodule Pitches. They are subtypes of the abstract Pitch type, support additive operations (+, -, zero), and have an order (via isless).Currently, only MIDI pitches are implemented, other representations will follow.Modules = [DigitalMusicology.Pitches]\nPrivate = false"
},

{
    "location": "reference.html#DigitalMusicology.PitchOps.allpcs",
    "page": "Reference",
    "title": "DigitalMusicology.PitchOps.allpcs",
    "category": "function",
    "text": "allpcs(P)\n\nReturns a list of all pitch classes of pitch type P.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.PitchOps.pc",
    "page": "Reference",
    "title": "DigitalMusicology.PitchOps.pc",
    "category": "function",
    "text": "Turn a pitch (or pitch collection) into a pitch class (collection)\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.PitchOps.transposeby",
    "page": "Reference",
    "title": "DigitalMusicology.PitchOps.transposeby",
    "category": "function",
    "text": "Transpose a pitch (collection) by some directed interval.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.PitchOps.transposeto",
    "page": "Reference",
    "title": "DigitalMusicology.PitchOps.transposeto",
    "category": "function",
    "text": "Transpose a pitch (collection) to a new reference point.\n\n\n\n"
},

{
    "location": "reference.html#Pitch-Operations-1",
    "page": "Reference",
    "title": "Pitch Operations",
    "category": "section",
    "text": "Common operations on pitches and pitch-based structures.Modules = [DigitalMusicology.PitchOps]\nPrivate = false"
},

{
    "location": "reference.html#DigitalMusicology.PitchCollections.FiguredBass",
    "page": "Reference",
    "title": "DigitalMusicology.PitchCollections.FiguredBass",
    "category": "type",
    "text": "Represents notes as a bass pitch with (a set of) figures.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.PitchCollections.PitchCollection",
    "page": "Reference",
    "title": "DigitalMusicology.PitchCollections.PitchCollection",
    "category": "type",
    "text": "An abstract supertype for pitch collections. Since a pitch collection should contain only one type of pitches, PitchCollection is parametric on a subtype of Pitch.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.PitchCollections.bass",
    "page": "Reference",
    "title": "DigitalMusicology.PitchCollections.bass",
    "category": "function",
    "text": "Returns the bass pitch of a figured bass representation.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.PitchCollections.figuredp-Tuple{Any}",
    "page": "Reference",
    "title": "DigitalMusicology.PitchCollections.figuredp",
    "category": "method",
    "text": "figuredp(pitches)\n\nRepresents pitches as a bass pitch and remaining pitch classes relative to the bass.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.PitchCollections.figuredpc-Tuple{Any}",
    "page": "Reference",
    "title": "DigitalMusicology.PitchCollections.figuredpc",
    "category": "method",
    "text": "figuredpc(pitches)\n\nRepresents pitches as a bass pitch class and remaining pitch classes relative to the bass.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.PitchCollections.figures",
    "page": "Reference",
    "title": "DigitalMusicology.PitchCollections.figures",
    "category": "function",
    "text": "Returns the figure pitch classes of a figured bass representation. (including 0 for the bass note)\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.PitchCollections.pbag-Tuple{Any}",
    "page": "Reference",
    "title": "DigitalMusicology.PitchCollections.pbag",
    "category": "method",
    "text": "Represents pitches as a bag of pitches.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.PitchCollections.pcbag-Tuple{Any}",
    "page": "Reference",
    "title": "DigitalMusicology.PitchCollections.pcbag",
    "category": "method",
    "text": "Represents pitches as a bag (vector) of pitch classes.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.PitchCollections.pcset-Tuple{Any}",
    "page": "Reference",
    "title": "DigitalMusicology.PitchCollections.pcset",
    "category": "method",
    "text": "Represents pitches as a set of pitch classes.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.PitchCollections.pitches-Tuple{Any}",
    "page": "Reference",
    "title": "DigitalMusicology.PitchCollections.pitches",
    "category": "method",
    "text": "pitches(pcoll)\n\nReturns a vector of all pitches in pcoll to the degree they can be reconstructed from the representation used by pcoll.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.PitchCollections.pitchiter",
    "page": "Reference",
    "title": "DigitalMusicology.PitchCollections.pitchiter",
    "category": "function",
    "text": "pitchiter(pitchcoll)\n\nIf the collection has an inner collection of all pitches, this function returns an iterator over the inner collection. The outer collection does not have to implement the iterator interface, since the default implementation for PitchCollections falls back to the inner iterator.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.PitchCollections.pset-Tuple{Any}",
    "page": "Reference",
    "title": "DigitalMusicology.PitchCollections.pset",
    "category": "method",
    "text": "Represent pitches as a set of absolute pitches.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.PitchCollections.refpitch",
    "page": "Reference",
    "title": "DigitalMusicology.PitchCollections.refpitch",
    "category": "function",
    "text": "refpitch(pitchcoll)\n\nReturns a unique reference pitch for the pitch collection. This reference should behave consistent with transposeto and transposeby\n\ntransposeto(coll, 0) == transposeby(coll, -refpitch(coll))\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.PitchCollections.transposeequiv",
    "page": "Reference",
    "title": "DigitalMusicology.PitchCollections.transposeequiv",
    "category": "function",
    "text": "transposeequiv(pitchcoll)\n\nTurns a pitch collection to a representative of its transpositional equivalence class.\n\n\n\n"
},

{
    "location": "reference.html#Pitch-Collections-1",
    "page": "Reference",
    "title": "Pitch Collections",
    "category": "section",
    "text": "The module PitchCollections provides structurs build out of pitches and pitch classes.Modules = [DigitalMusicology.PitchCollections]\nPrivate = false"
},

{
    "location": "reference.html#DigitalMusicology.Notes.Note",
    "page": "Reference",
    "title": "DigitalMusicology.Notes.Note",
    "category": "type",
    "text": "Notes are combinations of pitch and time information.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Notes.TimedNote",
    "page": "Reference",
    "title": "DigitalMusicology.Notes.TimedNote",
    "category": "type",
    "text": "A simple timed note. Pitch + onset + offset.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Notes.pitch",
    "page": "Reference",
    "title": "DigitalMusicology.Notes.pitch",
    "category": "function",
    "text": "pitch(note)\n\nReturns the pitch of a note\n\n\n\n"
},

{
    "location": "reference.html#Notes-1",
    "page": "Reference",
    "title": "Notes",
    "category": "section",
    "text": "Notes are pitches with some kind of time information. In its most simple form, a note consists of a pitch, an onset, and an offset. In a more complicated context, time information might be represented differently.Modules = [DigitalMusicology.Notes]\nPrivate = false"
},

{
    "location": "reference.html#DigitalMusicology.Timed.duration",
    "page": "Reference",
    "title": "DigitalMusicology.Timed.duration",
    "category": "function",
    "text": "duration(x)\n\nReturns the duration of some timed object x.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Timed.hasduration",
    "page": "Reference",
    "title": "DigitalMusicology.Timed.hasduration",
    "category": "function",
    "text": "hasduration(T)\n\nReturns true if T is a timed object with a duration.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Timed.hasoffset",
    "page": "Reference",
    "title": "DigitalMusicology.Timed.hasoffset",
    "category": "function",
    "text": "hasoffset(T)\n\nReturns true if T is a timed object with an offset.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Timed.hasonset",
    "page": "Reference",
    "title": "DigitalMusicology.Timed.hasonset",
    "category": "function",
    "text": "hasonset(T)\n\nReturns true if T is a timed object with an onset.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Timed.offset",
    "page": "Reference",
    "title": "DigitalMusicology.Timed.offset",
    "category": "function",
    "text": "offset(x)\n\nReturns the offset of some timed object x.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Timed.onset",
    "page": "Reference",
    "title": "DigitalMusicology.Timed.onset",
    "category": "function",
    "text": "onset(x)\n\nReturns the onset of some timed object x.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Timed.onsetcost-Tuple{Any,Any}",
    "page": "Reference",
    "title": "DigitalMusicology.Timed.onsetcost",
    "category": "method",
    "text": "onsetcost(timed1, timed2)\n\nReturns the distance between the onsets of timed1 and timed2.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Timed.skipcost-Tuple{Any,Any}",
    "page": "Reference",
    "title": "DigitalMusicology.Timed.skipcost",
    "category": "method",
    "text": "skipcost(timed1, timed2)\n\nReturns the distance between the offset of timed1 and the onset of timed2.\n\n\n\n"
},

{
    "location": "reference.html#Timing-1",
    "page": "Reference",
    "title": "Timing",
    "category": "section",
    "text": "The timing interface provides methods for querying information on timed objects. A timed object may have an onset, an offset, and a duration. As not every object has all of these properties, hasonset, hasoffset, and hasduration should be used to indicate, which pieces of information are available. It is usually sufficient to define either onset and offset or onset and duration.Furthermore, simple distance measures based on time are provided as skipcost and onsetcost.Modules = [DigitalMusicology.Timed]\nPrivate = false"
},

{
    "location": "reference.html#DigitalMusicology.Meter.TimeSignature",
    "page": "Reference",
    "title": "DigitalMusicology.Meter.TimeSignature",
    "category": "type",
    "text": "TimeSignature(num, denom)\n\nA simple time signature consisting of numerator and denomenator.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Meter.barbeatsubb-Union{Tuple{T,DigitalMusicology.Events.TimePartition{T,DigitalMusicology.Meter.TimeSignature}}, Tuple{T}} where T",
    "page": "Reference",
    "title": "DigitalMusicology.Meter.barbeatsubb",
    "category": "method",
    "text": "barbeatsubb(t, timesigmap)\n\nReturns a triple (bar, beat, subbeat) that indicates bar, beat, and subbeat of t in the context of timesigmap.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Meter.defaultmeter-Tuple{DigitalMusicology.Meter.TimeSignature}",
    "page": "Reference",
    "title": "DigitalMusicology.Meter.defaultmeter",
    "category": "method",
    "text": "defaultmeter(timesig [, warning=true])\n\nFor a time signature with sufficiently clear meter, returns the meter of the time signature. The meter is given as a list of group sizes in beats, i.e., only the numerator matters. For example, 2/2 -> [1], 4/4 -> [2,2], 3/4 -> [3], 3/8 -> 3, 6/8 -> [3,3], 12/8 -> [3,3,3,3].\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Meter.inbar-Union{Tuple{T,DigitalMusicology.Events.TimePartition{T,DigitalMusicology.Meter.TimeSignature}}, Tuple{T}} where T",
    "page": "Reference",
    "title": "DigitalMusicology.Meter.inbar",
    "category": "method",
    "text": "inbar(t, timesigmap)\n\nReturns the time point t relative to the beginning of the bar it lies in.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Meter.metricweight-Tuple{Rational{Int64},Array{Int64,1},Rational{Int64}}",
    "page": "Reference",
    "title": "DigitalMusicology.Meter.metricweight",
    "category": "method",
    "text": "metricweight(barpos, meter, beat)\n\nReturns the metric weight of a note starting at barpos from the beginning of a bar according to a meter. The meter is provided as a vector of group sizes in beats. E.g., a 4/4 meter consists of 2 groups of two quarters, so meter would be [2,2] and beat would be 1/4. The total length of the bar should be a multiple of beat. Each onset on a beat gets weight 1, the first beat of each group gets weight 2, and the first beat of the bar gets weight 4 (except if there is only one group, then 2). The weight of each subbeat is 1/2^p, where p is the number of prime factors needed to express the subbeat relative to its preceding beat and the beat unit. This way, tuplet divisions can be handled properly.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Meter.metricweight-Tuple{Rational{Int64},DigitalMusicology.Meter.TimeSignature}",
    "page": "Reference",
    "title": "DigitalMusicology.Meter.metricweight",
    "category": "method",
    "text": "metricweight(barpos, timesig)\n\nTries to guess meter and beat from timesig. Otherwise identical to metricweight(barpos, meter, beat).\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Meter.metricweight-Union{Tuple{T,DigitalMusicology.Events.TimePartition{T,DigitalMusicology.Meter.TimeSignature},Any,Any}, Tuple{T,DigitalMusicology.Events.TimePartition{T,DigitalMusicology.Meter.TimeSignature},Any}, Tuple{T,DigitalMusicology.Events.TimePartition{T,DigitalMusicology.Meter.TimeSignature}}, Tuple{T}} where T",
    "page": "Reference",
    "title": "DigitalMusicology.Meter.metricweight",
    "category": "method",
    "text": "metricweight(t, timesigmap [, meter [, beat]])\n\nReturns the metric weight at time point t in the context of timesigmap. Optionally, meter, and beat may be supplied as in metricweight(barpos, meter, beat) to override the default values inferred from the time signature at t.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Meter.@time_str-Tuple{Any}",
    "page": "Reference",
    "title": "DigitalMusicology.Meter.@time_str",
    "category": "macro",
    "text": "time\"num/denom\"\n\nCreates a TimeSignature object with numerator num and denominator denom.\n\n\n\n"
},

{
    "location": "reference.html#Meter-1",
    "page": "Reference",
    "title": "Meter",
    "category": "section",
    "text": "Time signatures and MeterModules = [DigitalMusicology.Meter]"
},

{
    "location": "reference.html#DigitalMusicology.Slices.Slice",
    "page": "Reference",
    "title": "DigitalMusicology.Slices.Slice",
    "category": "type",
    "text": "Slice(onset::N, duration::N, content::T) where {N<:Number, T}\n\nA slice of a pitches in a piece. Timing information (type N) is encoded as onset and duration with methods for obtaining and modifying the offset directly. The content of a slice is typically some representation of simultaneously sounding pitches (type T).\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Slices.setcontent-Union{Tuple{DigitalMusicology.Slices.Slice{N,T},Any}, Tuple{N}, Tuple{T}} where T where N",
    "page": "Reference",
    "title": "DigitalMusicology.Slices.setcontent",
    "category": "method",
    "text": "setcontent(ps, s)\n\nReturns a new slice with content ps.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Slices.setduration-Union{Tuple{DigitalMusicology.Slices.Slice{N,T},N}, Tuple{N}, Tuple{T}} where N where T",
    "page": "Reference",
    "title": "DigitalMusicology.Slices.setduration",
    "category": "method",
    "text": "setduration(dur::N, s)\n\nReturns a new slice with duration dur.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Slices.setoffset-Union{Tuple{DigitalMusicology.Slices.Slice{N,T},N}, Tuple{N}, Tuple{T}} where N where T",
    "page": "Reference",
    "title": "DigitalMusicology.Slices.setoffset",
    "category": "method",
    "text": "setoffset(off::N, s)\n\nReturns a new slice with offset off.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Slices.setonset-Union{Tuple{DigitalMusicology.Slices.Slice{N,T},N}, Tuple{N}, Tuple{T}} where N where T",
    "page": "Reference",
    "title": "DigitalMusicology.Slices.setonset",
    "category": "method",
    "text": "setonset(s, on)\n\nReturns a new slice with onset on.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Slices.sg_sumdur-Tuple{Any}",
    "page": "Reference",
    "title": "DigitalMusicology.Slices.sg_sumdur",
    "category": "method",
    "text": "Returns the sum of slice durations in a slice n-gram (excluding skipped time)\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Slices.sg_totaldur-Tuple{Any}",
    "page": "Reference",
    "title": "DigitalMusicology.Slices.sg_totaldur",
    "category": "method",
    "text": "Returns the total duration of a slice n-gram (including skipped time)\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Slices.unwrapslices-Tuple{Any}",
    "page": "Reference",
    "title": "DigitalMusicology.Slices.unwrapslices",
    "category": "method",
    "text": "Returns the pitch representations in a vector of slices.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Slices.updatecontent-Union{Tuple{Function,DigitalMusicology.Slices.Slice{N,T}}, Tuple{N}, Tuple{T}} where T where N",
    "page": "Reference",
    "title": "DigitalMusicology.Slices.updatecontent",
    "category": "method",
    "text": "updatecontent(f::Function, s::Slice)\n\nReturns a new slice with content f(content(s)).\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Slices.updateduration-Union{Tuple{Function,DigitalMusicology.Slices.Slice{N,T}}, Tuple{N}, Tuple{T}} where T where N",
    "page": "Reference",
    "title": "DigitalMusicology.Slices.updateduration",
    "category": "method",
    "text": "updateduration(f::Function, s)\n\nReturns a new slice with duration f(duration(s)).\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Slices.updateoffset-Union{Tuple{Function,DigitalMusicology.Slices.Slice{N,T}}, Tuple{N}, Tuple{T}} where T where N",
    "page": "Reference",
    "title": "DigitalMusicology.Slices.updateoffset",
    "category": "method",
    "text": "updateoffset(f::Function, s)\n\nReturns a new slice with offset f(offset(s)).\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Slices.updateonset-Union{Tuple{Function,DigitalMusicology.Slices.Slice{N,T}}, Tuple{N}, Tuple{T}} where T where N",
    "page": "Reference",
    "title": "DigitalMusicology.Slices.updateonset",
    "category": "method",
    "text": "updateonset(f::Function, s)\n\nReturns a new slice onset f(onset(s)).\n\n\n\n"
},

{
    "location": "reference.html#Slices-1",
    "page": "Reference",
    "title": "Slices",
    "category": "section",
    "text": "A piece of music might be represented as a list of slices by \"cutting\" it whenever a note starts or ends. A slice then has and onset, an offset, and a duration, and contains a collection of pitches that sound during the slice.Modules = [DigitalMusicology.Slices]\nPrivate = false"
},

{
    "location": "reference.html#DigitalMusicology.Events.IntervalEvent",
    "page": "Reference",
    "title": "DigitalMusicology.Events.IntervalEvent",
    "category": "type",
    "text": "IntervalEvent(onset::T, offset::T, content::C)\n\nAn event that spans a time interval. Has onset, offset, and duration.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Events.PointEvent",
    "page": "Reference",
    "title": "DigitalMusicology.Events.PointEvent",
    "category": "type",
    "text": "PointEvent(time::T, content::C)\n\nAn event that happens at a certain point in time. Has an onset but no offset or duration.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Events.TimePartition",
    "page": "Reference",
    "title": "DigitalMusicology.Events.TimePartition",
    "category": "type",
    "text": "TimePartition(breaks::Vector{T}, contents::Vector{C}\n\nPartitions a time span into half-open intervals [t0,t1), [t1,t2), ..., [tn-1,tn), where each interval has a content. The default constructor takes vectors of time points [t0...tn] and content [c1...cn]. There must be one more time point than content items. The whole partition has a total onset, offset, and duration.\n\nA TimePartition may be iterated over (as IntervalEvents) and subintervals can be accessed by their indices. While getting an index returns a complete IntervalEvent, setting an index sets only the content of the corresponding interval.\n\ntp[2] -> IEv<0.5-1.0>(\"foo\")\ntp[2] = \"bar\"\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Events.content",
    "page": "Reference",
    "title": "DigitalMusicology.Events.content",
    "category": "function",
    "text": "content(event)\n\nReturns the event\'s content.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Events.events-Tuple{DigitalMusicology.Events.TimePartition}",
    "page": "Reference",
    "title": "DigitalMusicology.Events.events",
    "category": "method",
    "text": "events(timepartition)\n\nReturns a vector of time-interval events that correspond to the subintervals and their content in timepartition.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Events.findevent-Union{Tuple{C}, Tuple{DigitalMusicology.Events.TimePartition{T,C},T}, Tuple{T}} where C where T",
    "page": "Reference",
    "title": "DigitalMusicology.Events.findevent",
    "category": "method",
    "text": "findevent(timepartition, time)\n\nReturns the index of the interval in timepartition that contains the timepoint time.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Events.movepoint!-Union{Tuple{C}, Tuple{DigitalMusicology.Events.TimePartition{T,C},Any,T}, Tuple{T}} where C where T",
    "page": "Reference",
    "title": "DigitalMusicology.Events.movepoint!",
    "category": "method",
    "text": "movepoint!(timepartition, index, distance)\n\nMoves the time point at index by a (positive or negative) distance, shrinkening or removing intervals that lie between the point\'s old and new position.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Events.setpoint!-Union{Tuple{C}, Tuple{DigitalMusicology.Events.TimePartition{T,C},Any,T}, Tuple{T}} where C where T",
    "page": "Reference",
    "title": "DigitalMusicology.Events.setpoint!",
    "category": "method",
    "text": "setpoint!(timepartition, index, newpos)\n\nMoves the time point at index to a new position, shrinkening or removing intervals that lie between the point\'s old and new position.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Events.split!-Union{Tuple{C}, Tuple{DigitalMusicology.Events.TimePartition{T,C},T,C,C}, Tuple{T}} where C where T",
    "page": "Reference",
    "title": "DigitalMusicology.Events.split!",
    "category": "method",
    "text": "split!(timepartition, at, before, after)\n\nSplits the subinterval [ti,ti+1) of timepartition that contains at into [ti,at) with content before and [at,t2] with content after.\n\n\n\n"
},

{
    "location": "reference.html#Events-1",
    "page": "Reference",
    "title": "Events",
    "category": "section",
    "text": "General containers for events. Events can be either based on time points or on time intervals. Both types of intervals Modules = [DigitalMusicology.Events]\nPrivate = false"
},

{
    "location": "reference.html#DigitalMusicology.Grams.grams-Union{Tuple{A,Int64}, Tuple{A}} where A<:AbstractArray",
    "page": "Reference",
    "title": "DigitalMusicology.Grams.grams",
    "category": "method",
    "text": "grams(arr, n)\n\nReturn all n-grams in arr. n must be positive, otherwise an error is thrown.\n\nExamples\n\njulia> grams([1,2,3], 2)\n2-element Array{Array{Int64,1},1}:\n [1, 2]\n [2, 3]\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Grams.indexskipgrams-Tuple{Any,Int64,Int64}",
    "page": "Reference",
    "title": "DigitalMusicology.Grams.indexskipgrams",
    "category": "method",
    "text": "indexskipgrams(itr, k, n)\n\nReturn all k-skip-n-grams over itr, with skips based on indices. For a custom cost function, use skipgrams.\n\nExamples\n\njulia> indexskipgrams([1,2,3,4,5], 2, 2)\n9-element Array{Any,1}:\n Any[1, 2]\n Any[1, 3]\n Any[2, 3]\n Any[1, 4]\n Any[2, 4]\n Any[3, 4]\n Any[2, 5]\n Any[3, 5]\n Any[4, 5]\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Grams.mapscapes-Union{Tuple{A}, Tuple{Function,A}} where A<:AbstractArray",
    "page": "Reference",
    "title": "DigitalMusicology.Grams.mapscapes",
    "category": "method",
    "text": "mapscapes(f, arr)\n\nMap f over all n-grams in arr for n=1:size(arr, 1).\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Grams.scapes-Union{Tuple{A}, Tuple{A}} where A<:AbstractArray",
    "page": "Reference",
    "title": "DigitalMusicology.Grams.scapes",
    "category": "method",
    "text": "scapes(arr)\n\nReturn all n-grams in arr for n=1:size(arr, 1).\n\nExamples\n\njulia> scapes([1,2,3])\n3-element Array{Array{Array{Int64,1},1},1}:\n Array{Int64,1}[[1], [2], [3]]\n Array{Int64,1}[[1, 2], [2, 3]]\n Array{Int64,1}[[1, 2, 3]]\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Grams.skipgrams",
    "page": "Reference",
    "title": "DigitalMusicology.Grams.skipgrams",
    "category": "function",
    "text": "skipgrams(input, k, n, cost [, pred] [, element_type=type] [, stable=false] [, p=1.0])\n\nReturns an iterator over all generalized k-skip-n-grams found in input.\n\nInstead of defining skips as index steps > 1, a general cost function is used. k is then an upper bound to the sum of all distances between consecutive elements in the gram.\n\nThe input needs to be iterable and monotonous with respect to the cost to a previous element:\n\n∀ i<j<l: cost(input[i], input[j]) ≤ cost(input[i], input[l])\n\nFrom this we know that if the current element increases the skip cost of some unfinished gram (prefix) to more than k, then all following elements will increase the cost at least as much, so we can discard the prefix.\n\nAn optional predicate function can be provided to filter potential skipgrams early. The predicate takes a PersistentList of input elements in reverse order (i.e., starting with the element that was added last). The predicate is applied to every prefix, so the list will have <=n elements. By default, all sequences of input elements are valid.\n\nIf element_type is provided, the resulting iterator will have a corresponding eltype. If not, it will try to guess the element type based on the input\'s eltype.\n\nIf stable is true, then the skipgrams will be ordered with respect to the position of their first element in the input stream. If stable is false (default), no particular order is guaranteed.\n\nThe parameter p allows to decide randomly (with probability p) whether a skipgram is included in the output in cases where the full list of skipgrams is to long. A coin with bias p^(1/n) will be flipped for every prefix applying to all completions of that prefix. Only if the coin flip for every prefix is positive, the skipgram will be included. This allows to save computation time by throwing away all completions of a discarded prefix, but it might introduce artifacts for the same reason.\n\nExamples\n\nfunction indexskipgrams(itr, k, n)\n    cost(x, y) = y[1] - x[1] - 1\n    grams = skipgrams_itr(enumerate(itr), k, n, cost)\n    map(sg -> map(x -> x[2], sg), grams)\nend\n\n\n\n"
},

{
    "location": "reference.html#Grams-1",
    "page": "Reference",
    "title": "Grams",
    "category": "section",
    "text": "Functions for generating n-grams, scapes, and skipgrams on streams.In order to generate classical skipgrams, use indexskipgrams. skipgrams provides more general variant, which allows a custom cost function and a compatibility predicate over pairs of input tokens. While the cost function generalizes the amount of skip from indices to arbitrary costs, the compatibility predicate allows, for example, to ensure non-overlapping skipgrams on overlapping input or early filtering of undesired skipgrams.Modules = [DigitalMusicology.Grams]\nPrivate = false"
},

{
    "location": "reference.html#DigitalMusicology.External.HumDrumString",
    "page": "Reference",
    "title": "DigitalMusicology.External.HumDrumString",
    "category": "type",
    "text": "HumDrumString(\"some humdrum\")\n\nA wrapper class that enables rendering and midi playback of humdrum code in the browser using verovio. When a HumDrumString is the result of a jupyter notebook cell, its content will be rendered to the output cell automatically.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.External.musescore",
    "page": "Reference",
    "title": "DigitalMusicology.External.musescore",
    "category": "function",
    "text": "musescore(id, [corpus])\n\nOpens the midi file of the piece that id refers to using Musescore. If corpus is not supplied, the current default corpus is used.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.External.verovio-Tuple{}",
    "page": "Reference",
    "title": "DigitalMusicology.External.verovio",
    "category": "method",
    "text": "verovio()\n\nSet up display of HumDrumStrings in Jupyter Notebooks.\n\n\n\n"
},

{
    "location": "reference.html#Viewing-1",
    "page": "Reference",
    "title": "Viewing",
    "category": "section",
    "text": "Helpers for viewing music.Midi files in a corpus can be viewed using MuseScore. (This function will probably be moved to the corpora package.)In Jupyter notebooks, Humdrum **kern strings can be viewed (and played) using Verovio (in fact, the branch of Verovio that is used in the Verovio HumDrum Viewer). Therefore, a musical structure can be visualized by translating it to a HumDrumString.For example, the Humdrum string**kern	**kern\n*clefF4	*clefG2\n*k[f#]	*k[f#]\n*M4/4	*M4/4\n=-	=-\n8GL	8ddL\n8AJ	8ccJ\n16BLL	2.b;\n16A	.\n16G	.\n16F#JJ	.\n2G;	.\n==	==\n*-	*-will be displayed as(Image: verovio svg)As Verovio can display other formats than Humdrum, corresponding types might be added in the future.Modules = [DigitalMusicology.External]\nPrivate = false"
},

{
    "location": "reference.html#DigitalMusicology.Corpora._getpiece",
    "page": "Reference",
    "title": "DigitalMusicology.Corpora._getpiece",
    "category": "function",
    "text": "_getpiece(id, Val{form}(), corpus)\n\nThis function is responsible for actually loading a piece. New corpus implementations should implement this method instead of getpiece, which is called by the user.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Corpora.allpieces",
    "page": "Reference",
    "title": "DigitalMusicology.Corpora.allpieces",
    "category": "function",
    "text": "allpieces([corpus])\n\nReturns all piece ids in corpus.\n\nallpieces(dir, [corpus])\n\nReturns all piece ids in and below dir.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Corpora.dirs",
    "page": "Reference",
    "title": "DigitalMusicology.Corpora.dirs",
    "category": "function",
    "text": "dirs([corpus])\n\nReturns all top-level piece directories in corpus.\n\ndirs(dir, [corpus])\n\nReturns all direct subdirectories of dir.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Corpora.findpieces",
    "page": "Reference",
    "title": "DigitalMusicology.Corpora.findpieces",
    "category": "function",
    "text": "findpieces(searchstring[, corpus])\n\nSearches the corpus for pieces matching searchstring. Returns a dataframe of matching rows.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Corpora.getcorpus-Tuple{}",
    "page": "Reference",
    "title": "DigitalMusicology.Corpora.getcorpus",
    "category": "method",
    "text": "Get the currently set corpus. Throws an error, if the corpus is not set.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Corpora.getpiece",
    "page": "Reference",
    "title": "DigitalMusicology.Corpora.getpiece",
    "category": "function",
    "text": "getpiece(id, form, [corpus])\n\nLoads a piece in some representation. Piece ids are strings, but their exact format depends on the given corpus.\n\nForms are identified by keywords, e.g.\n\n:slices\n:slices_df\n:notes\n\nbut the supported keywords depend on the corpus.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Corpora.getpieces",
    "page": "Reference",
    "title": "DigitalMusicology.Corpora.getpieces",
    "category": "function",
    "text": "getpieces(ids, form, [datadir])\n\nLike getpiece but takes multiple ids and returns an iterator over the resulting pieces.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Corpora.ls",
    "page": "Reference",
    "title": "DigitalMusicology.Corpora.ls",
    "category": "function",
    "text": "ls([corpus])\n\nReturns all top-level pieces and directories in corpus at once.\n\nls(dir, [corpus])\n\nReturns all subdirectories and pieces in dir at once.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Corpora.piecepath",
    "page": "Reference",
    "title": "DigitalMusicology.Corpora.piecepath",
    "category": "function",
    "text": "piecepath(id, cat, ext, [corpus])\n\nReturns the full path to the file of piece id in category cat with extension ext in corpus.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Corpora.pieces",
    "page": "Reference",
    "title": "DigitalMusicology.Corpora.pieces",
    "category": "function",
    "text": "pieces(dir, [corpus])\n\nReturns the piece ids in dir.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Corpora.setcorpus-Tuple{DigitalMusicology.Corpora.Corpus}",
    "page": "Reference",
    "title": "DigitalMusicology.Corpora.setcorpus",
    "category": "method",
    "text": "Set the current corpus.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Corpora.supportedforms",
    "page": "Reference",
    "title": "DigitalMusicology.Corpora.supportedforms",
    "category": "function",
    "text": "supportedforms([corpus])\n\nReturns a list of symbols that can be passed to the form parameter in piece loading functions for the given corpus.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Corpora.topdir",
    "page": "Reference",
    "title": "DigitalMusicology.Corpora.topdir",
    "category": "function",
    "text": "topdir([corpus])\n\nReturns the main piece directory of corpus.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Corpora.unsetcorpus-Tuple{}",
    "page": "Reference",
    "title": "DigitalMusicology.Corpora.unsetcorpus",
    "category": "method",
    "text": "Reset the current corpus to NoCorpus().\n\n\n\n"
},

{
    "location": "reference.html#Corpora-1",
    "page": "Reference",
    "title": "Corpora",
    "category": "section",
    "text": "Musical corpora contain pieces in various file formats and additional metadata. As different corpora have a different internal layout, DM.jl provides an interface that can be implemented for each type of corups that is used. A single piece is identified by a piece id and can be loaded in different representations that may contain different pieces of information about the piece, e.g. as a note list from MIDI files or as Metadata from JSON or CSV files. The implementation of a corpus must provide methods to list all possible piece ids. Piece ids may be organized hierarchically, e.g., in order to reflect the directory structure of the corpus.Each corpus implements its own subtype of Corpus, on which the implementation of the general interface dispatches. For convenience, a currently active corpus can be set using setcorpus. Corpus interface methods called without the corpus argument default to this currently active corpus. Each corpus implementation should provide a convenience function useX that creates a corpus object and sets it as active.Modules = [DigitalMusicology.Corpora]\nPrivate = false"
},

{
    "location": "reference.html#DigitalMusicology.Corpora.LAC.meta",
    "page": "Reference",
    "title": "DigitalMusicology.Corpora.LAC.meta",
    "category": "function",
    "text": "meta([crp::LACCorpus])\n\nReturns the corpus\' meta-dataframe.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Corpora.LAC.yearbins",
    "page": "Reference",
    "title": "DigitalMusicology.Corpora.LAC.yearbins",
    "category": "function",
    "text": "yearbins(timespan [, reference=0 [, corpus]])\n\nReturns piece ids in a list of bins as named tuples (onset, offset, bin, ids). The bins are timespan years wide and start at reference. Only pieces with a readable composition_year metadata entry are returned. The year is read from the composition_year column by taking the first sequence of 4 digits in each row.\n\n\n\n"
},

{
    "location": "reference.html#Large-Archive-Corpus-1",
    "page": "Reference",
    "title": "Large Archive Corpus",
    "category": "section",
    "text": "A \"LAC\" contains an index CSV file and a set of toplevel directories according to different representations of the content of the corpus. Each of these \"type\"-directories contains the same folder hierarchy below it, including the names of the actual data files, except the file extension. The id of a piece is therefore its path in this common substructure, separated with / and ending in the filename without extension. The actual file of a certain type can then be retrieved from the id by prepending the name of the type-directory and appending the appropriate file extension.Modules = [DigitalMusicology.Corpora.LAC]\nPrivate = false"
},

{
    "location": "reference.html#DigitalMusicology.Corpora.Kern.kerncrp-Tuple{String}",
    "page": "Reference",
    "title": "DigitalMusicology.Corpora.Kern.kerncrp",
    "category": "method",
    "text": "kerncrp(dir)\n\nCreates a new KernCorpus with data directory dir.\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Corpora.Kern.usekern-Tuple{String}",
    "page": "Reference",
    "title": "DigitalMusicology.Corpora.Kern.usekern",
    "category": "method",
    "text": "usekern(dir)\n\nCreates a new KernCorpus and sets it as the default corpus.\n\n\n\n"
},

{
    "location": "reference.html#Kern-Corpus-(WIP)-1",
    "page": "Reference",
    "title": "Kern Corpus (WIP)",
    "category": "section",
    "text": "A Kern corpus provides access to the Humdrum **kern corpora provided by Craig Sapp like the Mozart Piano Sonatas. Note that running some extra commands like make midi-norep might be required first.Currently, the files can only be read from MIDI, not directly from Humdrum, but this is being worked on.Modules = [DigitalMusicology.Corpora.Kern]\nPrivate = false"
},

]}
