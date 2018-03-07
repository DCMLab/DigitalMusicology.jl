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
    "text": "Take a look at the referenceTutorials and explanations will follow."
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
    "location": "reference.html#DigitalMusicology.Slices.Slice",
    "page": "Reference",
    "title": "DigitalMusicology.Slices.Slice",
    "category": "type",
    "text": "Slice(onset::N, duration::N, content::T) where {N<:Number, T}\n\nA slice of a pitches in a piece. Timing information (type N) is encoded as onset and duration with methods for obtaining and modifying the offset directly. The content of a slice is typically some representation of simultaneously sounding pitches (type T).\n\n\n\n"
},

{
    "location": "reference.html#DigitalMusicology.Slices.content-Union{Tuple{DigitalMusicology.Slices.Slice{N,T}}, Tuple{N}, Tuple{T}} where N where T",
    "page": "Reference",
    "title": "DigitalMusicology.Slices.content",
    "category": "method",
    "text": "Returns the content of slice s.\n\n\n\n"
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
    "text": "indexskipgrams(itr, k, n)\n\nReturn all k-skip-n-grams over itr, with skips based on indices. For a custom cost function, use skipgrams_itr.\n\nExamples\n\njulia> indexskipgrams([1,2,3,4,5], 2, 2)\n9-element Array{Any,1}:\n Any[1, 2]\n Any[1, 3]\n Any[2, 3]\n Any[1, 4]\n Any[2, 4]\n Any[3, 4]\n Any[2, 5]\n Any[3, 5]\n Any[4, 5]\n\n\n\n"
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
    "text": "skipgrams(input, k, n, cost[, pred][, element_type=type][, stable=false])\n\nReturns an iterator over all generalized k-skip-n-grams found in input.\n\nInstead of defining skips as index steps > 1, a general cost function is used. k is then an upper bound to the sum of all distances between consecutive elements in the gram.\n\nThe input needs to be iterable and monotonous with respect to the cost to a previous element:\n\n∀ i<j<l: cost(input[i], input[j]) ≤ cost(input[i], input[l])\n\nFrom this we know that if the current element increases the skip cost of some unfinished gram (prefix) to more than k, then all following elements will increase the cost at least as much, so we can discard the prefix.\n\nAn optional predicate function can be provided to filter potential skipgrams early. The predicate takes a PersistentList of input elements in reverse order (i.e., starting with the element that was added last). The predicate is applied to every prefix, so the list will have <=n elements. By default, all sequences of input elements are valid.\n\nIf element_type is provided, the resulting iterator will have a corresponding eltype. If not, it will try to guess the element type based on the input\'s eltype.\n\nIf stable is true, then the skipgrams will be ordered with respect to the position of their first element in the input stream. If stable is false (default), no particular order is guaranteed.\n\nExamples\n\nfunction indexskipgrams(itr, k, n)\n    cost(x, y) = y[1] - x[1] - 1\n    grams = skipgrams_itr(enumerate(itr), k, n, cost)\n    map(sg -> map(x -> x[2], sg), grams)\nend\n\n\n\n"
},

{
    "location": "reference.html#Grams-1",
    "page": "Reference",
    "title": "Grams",
    "category": "section",
    "text": "Functions for generating n-grams, scapes, and skipgrams on streams.In order to generate classical skipgrams, use skipgrams. skipgrams_itr provides more general variant, which allows a custom cost function and a compatibility predicate over pairs of input tokens. While the cost function generalizes the amount of skip from indices to arbitrary costs, the compatibility predicate allows, for example, to ensure non-overlapping skipgrams on overlapping input or early filtering of undesired skipgrams.Modules = [DigitalMusicology.Grams]\nPrivate = false"
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

]}
