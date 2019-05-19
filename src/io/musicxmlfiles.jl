module MusicXMLFiles

using LightXML
using DataFrames
using DigitalMusicology

export musicxmlnotes, loadwithids

testfile = "/home/chfin/Uni/phd/data/csapp/mozart-piano-sonatas/musicxml/sonata03-3.xml"

# XML Helpers
#############

haselem(node, subname) = find_element(node, subname) != nothing

firstcont(node, subname) = LightXML.content(node[subname][1])

firstint(node, subname, default=:error) =
    if !haselem(node, subname)
        if default == :error
            error("no default for $subname in $(node)")
        else
            default
        end
    else
        parse(Int, firstcont(node, subname))
    end

# Adding IDs to a MusicXML document
###################################

"""
    loadwithids(file; keep=false)

Loads a MusicXML file and adds `xml:id` attributes to its note elements.
If `keep` is `true`, then existing `xml:id` values are not replaced.
Returns an `XMLDocument`.
"""
function loadwithids(file; keep=false)
    doc = parse_file(file)
    addids!(root(doc), 0, keep)
    doc
end

function addids!(elem, i, keep)
    if name(elem) == "note" && (!keep || !has_attribute(elem, "xml:id"))
        set_attribute(elem, "xml:id", "note$i")
        i += 1
    end
    for child in child_elements(elem)
        i = addids!(child, i, keep)
    end
    i
end

# Parsing MusicXML to note list
###############################

# TODOs:
# - timewise parsing
# - modelling repetitions:
#   - unfold and use duplicate IDs
#   - allows grouping by id: each note has 1 on/off per repetition

const NoteTuple = Tuple{Rational{Int},Rational{Int},Int,Int,Union{String,Missing},Int}

mutable struct PartState
    div :: Int
    time :: Rational{Int}
    prev_time :: Rational{Int}
    trans_dia :: Int
    trans_chrom :: Int
    tied :: Vector{NoteTuple}
    timesig :: TimeSignature
end
PartState() = PartState(1, 0//1, 0//1, 0, 0, [], TimeSignature(4,4))

"""
    readmusicxml(file)
    readmusicxml(doc)

Takes a MusicXML file or `XMLDocument`.
Returns a pair consisting of a notelist `DataFrame`
and a vector of `TimeSigMap`s, one for each part.
The frame has 6 columns: `onset`, `offset`, `pitch_dia`, `pitch_chrom`, `id`, and `part`.
Onset and offset are `Rational{Int}`s, diatonic and chromatic pitch are `Int`s
representing diatonic and chromatic steps above C0, respectively.
The ID is a `String` that corresponds to the `xml:id` of the note element.
The note's part is indicated as an integer index.

Tied notes are represented only once and take the first supplied id
of the written notes that are part of a tied note.
"""
function readmusicxml end

function readmusicxml(file::String)
    doc = parse_file(file)
    try
        readmusicxml(doc)
    finally
        free(doc)
    end
end

function readmusicxml(doc::XMLDocument)
    rootelem = root(doc)
    if name(rootelem) == "score-partwise"
        partwise(rootelem)
    elseif name(rootelem) == "score-timewise"
        timewise(rootelem)
    else
        error("unknown xml structure (probably not MusicXML)")
    end
end

function newnotedf()
    DataFrame(onset=Rational{Int}[],
              offset=Rational{Int}[],
              pitch_dia=Int[],
              pitch_chrom=Int[],
              id=Union{String,Missing}[],
              part=Int[])
end

function partwise(score)
    notes = newnotedf()
    timesigs = TimeSigMap{Rational{Int}}[]
    for (i, part) in enumerate(score["part"])
        ns, t = readpart(part, i)
        append!(notes, ns)
        push!(timesigs, t)
    end
    sort!(notes, [:onset])
    notes, timesigs
end

function readpart(part, parti)
    state = PartState()
    notes = newnotedf()
    timesigs = TimeSigMap{Rational{Int}}(Rational{Int}[0//1], TimeSignature[])

    firstbar = true
    # go through each measure and process all important elements, collecting the notes
    for measure in part["measure"]
        for node in child_elements(measure)
            if name(node) == "attributes"
                attribs!(node, timesigs, state)
            elseif name(node) == "note"
                note!(node, notes, state, parti)
            elseif name(node) == "forward"
                forward!(node, state)
            elseif name(node) == "backup"
                backup!(node, state)
            end
        end
        if firstbar
            # first bar incomplete?
            if state.time < duration(state.timesig)
                # move first TS to beginning of first complete bar
                movepoint!(timesigs, 1, state.time)
            end
            firstbar = false
        end
    end
    # add remaining open tied notes, just in case there are some left
    for note in state.tied
        push!(notes, note)
    end
    # close last time signature span
    split!(timesigs, state.time, state.timesig, state.timesig)

    notes, timesigs
end

notenames = Dict(
    "C" => (0, 0),
    "D" => (1, 2),
    "E" => (2, 4),
    "F" => (3, 5),
    "G" => (4, 7),
    "A" => (5, 9),
    "B" => (6, 11)
)

function attribs!(attr, timesigs, state)
    for node in child_elements(attr)
        if name(node) == "divisions"
            state.div = parse(Int, LightXML.content(node))
        elseif name(node) == "transpose"
            state.trans_chrom = firstint(node, "chromatic")
            state.trans_dia = firstintor(node, "diatonic", 0)
            octs = firstintor(node, "octave-change", 0)
            state.trans_dia += 7 * octs
            state.trans_chrom += 12 * octs
        elseif name(node) == time
            num = firstint(node, "beats")
            denom = firstint(node, "beat-type")
            if state.time > 0//1 # if first TS, no need to split
                split!(timesigs, state.time, state.timesig, state.timesig)
            end
            state.timesig = TimeSignature(num,denom)
        end
    end
end

function note!(note, notes, state, parti)
    # time
    duration = firstint(note, "duration", 0) // (state.div * 4) # might be grace note
    if haselem(note, "chord")
        onset = state.prev_time
    else
        onset = state.time
        state.prev_time = state.time
        state.time += duration
    end
    offset = onset + duration

    # note or rest?
    if haselem(note, "pitch") && !haselem(note, "rest")
        # pitch
        epitch = note["pitch"][1]
        oct = firstint(epitch, "octave")
        alt = firstint(epitch, "alter", 0)
        
        dia, chrom = notenames[firstcont(epitch, "step")]
        dia += state.trans_dia + oct * 7
        chrom += alt + state.trans_chrom + oct * 12
        
        # id
        attr = attributes_dict(note)
        id = get(attr, "id", get(attr, "xml:id", missing))
        
        # tie stop?
        if any(t -> attribute(t, "type") == "stop", note["tie"])
            
            # find corresponding open note
            istart = findfirst(state.tied) do (ton, toff, tdia, tchrom, tid)
                toff == onset && tdia == dia && tchrom == chrom
            end

            # combine info
            if istart != nothing
                (ton, toff, tdia, tchrom, tid) = state.tied[istart]
                onset = ton
                if ismissing(tid)
                    id = tid
                end
                deleteat!(state.tied, istart) # delete open note
            end
        end

        # tie start?
        if any(t -> attribute(t, "type") == "start", note["tie"])
            # note starts tie: add to open notes
            push!(state.tied, (onset, offset, dia, chrom, id, parti))
        else # note is complete: add to output
            push!(notes, (onset, offset, dia, chrom, id, parti))
        end
    end
end

function forward!(node, state)
    duration = firstint(node, "duration", 0) // (state.div * 4)
    state.time += duration
    state.prev_time = state.time # reset
end

function backup!(node, state)
    duration = firstint(node, "duration", 0) // (state.div * 4)
    state.time -= duration
    state.prev_time = state.time # reset
end

end
