module MusicXMLFiles

using LightXML
using DataFrames
using ...DigitalMusicology

export readmusicxml, loadwithids

# XML Helpers
#############

haselem(node, subname) = find_element(node, subname) != nothing

firstcont(node, subname) = strip(LightXML.content(node[subname][1]))

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

readints(str) = map(s -> parse(Int, strip(s)), split(str, ","))


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

# Control Flow
##############

# commands in of precedence: closing low, closing high, opening high, opening low
@enum FlowCommand begin
    bwrepeat
    stopending
    fine
    dacapo
    dalsegno
    tocoda
    coda
    segno
    startending
    fwrepeat
end

struct FlowMarker
    command :: FlowCommand
    time :: Rational{Int}
    only :: Union{Vector{Int},Nothing}
    repeats :: Union{Int,Nothing}
    name :: Union{String,Nothing}
end
# flowm(cmd, time; only=nothing, repeats=nothing) = FlowMarker(cmd, time, only, repeats)

const RepStack = Vector{Tuple{Rational{Int}, Int, Vector{FlowMarker}}}

mutable struct FlowState
    now :: Rational{Int}
    markers
    segnos :: Dict{String,Tuple{Vector{FlowMarker}, Rational{Int}, RepStack}}
    stack :: RepStack
    gcount :: Dict{Tuple{FlowCommand, Rational{Int}}, Int}
    jumps :: Vector{Union{Tuple{Rational{Int}, Rational{Int}}, Rational{Int}}}
end

currentrep(state) = isempty(state.stack) ? 1 : state.stack[end][2]

pushrepeat!(state) = push!(state.stack, (state.now, 1, state.markers))

function gorepeat!(state)
    if isempty(state.stack)
        @warn "Don't know where to repeat from. Did you forget a forward repeat sign?"
        #restore!(state, allmarkers, 0//1, [(0//1, 2, allmarkers)])
    else
        (t, n, markers) = pop!(state.stack) #[end]
        restore!(state, markers, t, push!(state.stack, (t, n+1, markers)))
    end
end

poprepeat!(state) = if !isempty(state.stack); pop!(state.stack) end

function skipuntil!(state, com, tend; name=nothing)
    i = 1
    while state.markers[i].command != com || state.markers[i].name != name
        i += 1
    end
    remaining = state.markers[i:end]
    t = isempty(remaining) ? tend : remaining[1].time
    state.markers = remaining
    push!(state.jumps, (state.now, t))
    state.now = t
end

function restore!(state, markers, t, stack)
    push!(state.jumps, (state.now, t))
    state.markers = markers
    state.now = t
    state.stack = stack
end

function unfoldflow(markers, tend)
    allmarkers = sort(markers, by=fm -> (fm.time, fm.command))
    beginning = (0//1, 1, allmarkers) # repetition stack item for beginning of the piece
    state = FlowState(0//1, allmarkers, Dict(), [beginning], Dict(), [])
    
    while !isempty(state.markers)
        marker = state.markers[1]
        state.markers = state.markers[2:end]
        state.now = marker.time
        # TODO: update state.gcount
        
        if marker.command == fwrepeat
            pushrepeat!(state)
        elseif marker.command == bwrepeat
            if currentrep(state) < marker.repeats
                gorepeat!(state)
            else
                poprepeat!(state)
            end
        elseif marker.command == startending
            if currentrep(state) ∉ marker.only
                skipuntil!(state, stopending, tend)
            end
        elseif marker.command == fine
            times = state.gcount[(marker.command, marker.time)]
            if (marker.only == nothing && times > 1) || times ∈ marker.only
                push!(state.jumps, state.now)
                break
            end
        elseif marker.command == dacapo
            times = state.gcount[(marker.command, marker.time)]
            if marker.only == nothing || times ∈ marker.only
                restore!(state, allmarkers, 0//1, [beginning])
            end
        elseif marker.command == segno
            state.segnos[marker.name] = (state.markers, state.now, copy(state.stack))
        elseif marker.command == dalsegno
            times = state.gcount[(marker.command, marker.time)]
            if (marker.only == nothing || times ∈ marker.only) &&
                haskey(state.segnos, marker.name)
                (m, t, s) = state.segnos[marker.name]
                restore!(state, m, t, s)
            end
        elseif marker.command == tocoda
            times = state.gcount[(marker.command, marker.time)]
            if (marker.only == nothing && times > 1) || times ∈ marker.only
                skipuntil!(state, coda, tend; name=name)
            end
        end
    end

    if isempty(state.jumps)
        push!(state.jumps, tend)
    else
        if isa(state.jumps[end], Tuple)
            push!(state.jumps, tend)
        end
    end

    out = Tuple{Rational{Int}, Rational{Int}}[]
    last = 0//1
    for jump in state.jumps
        if isa(jump, Rational)
            push!(out, (last, jump))
            break
        else
            push!(out, (last, jump[1]))
            last = jump[2]
        end
    end

    out
end


# Parsing MusicXML to note list
###############################

# TODOs:
# - timewise parsing
# - apply unfolding to time signatures!!!

const NoteTuple = Tuple{Rational{Int},Rational{Int},Int,Int,Union{String,Missing},Int}

mutable struct PartState
    div :: Int
    time :: Rational{Int}
    prev_time :: Rational{Int}
    trans_dia :: Int
    trans_chrom :: Int
    tied :: Vector{NoteTuple}
    timesig :: TimeSignature
    flow :: Vector{FlowMarker}
end
PartState() = PartState(1, 0//1, 0//1, 0, 0, NoteTuple[], TimeSignature(4,4), FlowMarker[])

pushflow!(state, cmd; only=nothing, repeats=nothing, name=nothing) =
    push!(state.flow, FlowMarker(cmd, state.time, only, repeats, name))

"""
    readmusicxml(file; unfold=true)
    readmusicxml(doc; unfold=true)

Takes a MusicXML file or `XMLDocument`.
Returns a named tuple `(notes, timsigs, flows)`, consisting of a notelist `DataFrame`,
a vector of `TimeSigMap`s, and a vector of control flows.
The latter two (`timesigs` and `flows`) both contain one element per part,
with indices corresponding to the `part` column in `notes`.

The frame has 6 columns: `onset`, `offset`, `dia`, `chrom`, `id`, and `part`.
Onset and offset are `Rational{Int}`s, diatonic and chromatic pitch are `Int`s
representing diatonic and chromatic steps above C0, respectively.
The ID is a `String` that corresponds to the `xml:id` of the note element.
The note's part is indicated as an integer index.
Tied notes are represented only once and take the first supplied id
of the written notes that are part of a tied note.

Control flow is represented as a vector of sections where each section is a pair `(t1, t2)`,
indicating the notated onset and offset of the section.

`unfold` determines whether the piece should be unfolded wrt. its control flow,
i.e. repetitions, DC, DS, coda, etc.
If `unfold` is `true`, the resulting notes will be as heart, i.e. the same note
can occur several times if repeated.
In that case the same id will be used for all repetitions of the same notated notes,
but the onset and offset of notes will correspond to the performance
and thus differ for repetitions of a note.
If `unfold` is `false`, the every note will occur just once
and timings will correspond to the notation,
ignoring all marks of controll flow.
In any case, the section list for each part will be returned as well,
so conversion between both representations is possible.
"""
function readmusicxml end

function readmusicxml(file::String; unfold=true)
    doc = parse_file(file)
    try
        readmusicxml(doc, unfold=unfold)
    finally
        free(doc)
    end
end

function readmusicxml(doc::XMLDocument; unfold=true)
    rootelem = root(doc)
    if name(rootelem) == "score-partwise"
        partwise(rootelem, unfold)
    elseif name(rootelem) == "score-timewise"
        timewise(rootelem, unfold)
    else
        error("unknown xml structure (probably not MusicXML)")
    end
end

function newnotedf()
    DataFrame(onset=Rational{Int}[],
              offset=Rational{Int}[],
              dia=Int[],
              chrom=Int[],
              id=Union{String,Missing}[],
              part=Int[])
end

function partwise(score, unfold)
    notes = newnotedf()
    timesigs = TimeSigMap{Rational{Int}}[]
    flows = Vector{Tuple{Rational{Int}, Rational{Int}}}[]
    for (i, part) in enumerate(score["part"])
        ns, t, f = readpart(part, i, unfold)
        append!(notes, ns)
        push!(timesigs, t)
        push!(flows, f)
    end
    sort!(notes, [:onset])
    (notes=notes, timesigs=timesigs, flows=flows)
end

function readpart(part, parti, unfold)
    state = PartState()
    notes = newnotedf()
    timesigs = TimeSigMap{Rational{Int}}(Rational{Int}[0//1], TimeSignature[])

    firstbar = true
    # go through each measure and process all important elements, collecting the notes
    for measure in part["measure"]
        for node in child_elements(measure)
            if name(node) == "barline"
                barline!(node, state)
            elseif name(node) == "attributes"
                attribs!(node, timesigs, state)
            elseif name(node) == "direction"
                direction!(node, state)
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


    sections = unfoldflow(state.flow, state.time)
    if unfold
        now = 0//1
        unfolded = newnotedf()
        for (t1, t2) in sections
            shift = t -> t + now - t1
            secnotes = notes[(notes.offset .> t1) .& (notes.onset .< t2), :]
            secnotes.onset = map(shift, secnotes.onset)
            secnotes.offset = map(shift, secnotes.offset)
            append!(unfolded, secnotes)
            now = shift(t2)
        end
        notes = unfolded
    end
    
    notes, timesigs, sections
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

function barline!(bar, state)
    for rep in bar["repeat"]
        dir = attribute(rep, "direction")
        if dir == "forward"
            pushflow!(state, fwrepeat)
        elseif dir == "backward"
            times = has_attribute(rep, "times") ? attribute(rep, "times") : 2
            pushflow!(state, bwrepeat; repeats=times)
        end
    end

    for ending in bar["ending"]
        typ = attribute(ending, "type")
        if typ == "start"
            times = readints(attribute(ending, "number"))
            pushflow!(state, startending; only=times)
        elseif typ == "stop"
            pushflow!(state, stopending)
        end
    end
end

function attribs!(attr, timesigs, state)
    for node in child_elements(attr)
        if name(node) == "divisions"
            state.div = parse(Int, LightXML.content(node))
        elseif name(node) == "transpose"
            state.trans_chrom = firstint(node, "chromatic")
            state.trans_dia = firstint(node, "diatonic", 0)
            octs = firstint(node, "octave-change", 0)
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

function direction!(dir, state)
    for sound in dir["sound"]
        only = has_attribute(sound, "time-only") ? readints(attribute(sound, "time-only")) : nothing
        if has_attribute(sound, "dacapo")
            pushflow!(state, dacapo; only=only)
        end
        if has_attribute(sound, "fine")
            pushflow!(state, fine)
        end
        if has_attribute(sound, "segno")
            pushflow!(state, segno; name=attribute(sound, "segno"), only=only)
        end
        if has_attribute(sound, "dalsegno")
            pushflow!(state, dalsegno; name=attribute(sound, "dalsegno"))
        end
        if has_attribute(sound, "tocoda")
            pushflow!(state, tocoda; name=attribute(sound, "tocoda"), only=only)
        end
        if has_attribute(sound, "coda")
            pushflow!(state, coda; name=attribute(sound, "coda"))
        end
        if has_attribute(sound, "forward-repeat")
            pushflow!(state, fwrepeat)
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
                if !ismissing(tid)
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
