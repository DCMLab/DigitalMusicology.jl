module MusicXMLFiles

using LightXML
using DataFrames

export musicxmlnotes

testfile = "/home/chfin/Uni/phd/data/csapp/mozart-piano-sonatas/musicxml/sonata03-3.xml"

# TODOs:
# - timewise parsing
# - modelling repetitions:
#   - unfold and use duplicate IDs
#   - allows grouping by id: each note has 1 on/off per repetition

const NoteTuple = Tuple{Rational{Int},Rational{Int},Int,Int,Union{String,Missing}}

mutable struct PartState
    div :: Int
    time :: Rational{Int}
    prev_time :: Rational{Int}
    trans_dia :: Int
    trans_chrom :: Int
    tied :: Vector{NoteTuple}
end
PartState() = PartState(1, 0//1, 0//1, 0, 0, [])

function musicxmlnotes(file)
    doc = parse_file(file)
    rootelem = root(doc)
    if name(rootelem) == "score-partwise"
        notes = partwise(rootelem)
    elseif name(rootelem) == "score-timewise"
        notes = timewise(rootelem)
    else
        free(doc)
        error("cannot read $file")
    end
    # free(doc)
    notes
end

function newnotedf()
    DataFrame(onset=Rational{Int}[],
              offset=Rational{Int}[],
              pitch_dia=Int[],
              pitch_chrom=Int[],
              id=Union{String,Missing}[])
end

function partwise(score)
    notes = newnotedf()
    for part in score["part"]
        append!(notes, partnotes(part))
    end
    sort!(notes, [:onset])
end

function partnotes(part)
    state = PartState()
    notes = newnotedf()
    for measure in part["measure"]
        for node in child_elements(measure)
            if name(node) == "attributes"
                attribs!(node, state)
            elseif name(node) == "note"
                note!(node, notes, state)
            elseif name(node) == "forward"
                forward!(node, state)
            elseif name(node) == "backup"
                backup!(node, state)
            end
        end
    end
    notes
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

haselem(node, subname) = find_element(node, subname) != nothing

firstcont(node, subname) = content(node[subname][1])

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

function attribs!(attr, state)
    for node in child_elements(attr)
        if name(node) == "divisions"
            state.div = parse(Int, content(node))
        elseif name(node) == "transpose"
            state.trans_chrom = firstint(node, "chromatic")
            state.trans_dia = firstintor(node, "diatonic", 0)
            octs = firstintor(node, "octave-change", 0)
            state.trans_dia += 7 * octs
            state.trans_chrom += 12 * octs 
        end
    end
end

function note!(note, notes, state)
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
            push!(state.tied, (onset, offset, dia, chrom, id))
        else # note is complete: add to output
            push!(notes, (onset, offset, dia, chrom, id))
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
