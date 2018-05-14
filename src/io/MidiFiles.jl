module MidiFiles

export midifilenotes

using MIDI
using DataFrames
using Ratios
using DigitalMusicology
using DigitalMusicology.Helpers: coprime

# Time Division
# =============

abstract type TimeDiv end

struct PulsesPerQuarter <: TimeDiv
    ppq :: SimpleRatio{Int}
end

struct TicksPerSecond <: TimeDiv
    tps :: SimpleRatio{Int}
end
TicksPerSecond(fps::Int, tpf::Int) =
    TicksPerSecond(round(tpf * (fps==29 ? 29.97 : fps)))

"""
    timeratios(timediv, tempo) -> (w/tick, s/tick)

Takes a TimeDiv and a tempo in μs per quarter and returns
rationals for whole notes per ticks and seconds per ticks.
Note that quarter based units are converted to whole notes.
"""
function timeratios end

timeratios(tdiv::PulsesPerQuarter, μpq) =
    (coprime(1/(4*tdiv.ppq)), μpq/(1_000_000.0*tdiv.ppq))

timeratios(tdiv::TicksPerSecond, μpq) =
    (coprime(250_000/(tdiv.tps*μpq)), 1.0/tdiv.tps)

# Track Events
# ============

struct UpEvent
    dT :: Int
    ev :: TrackEvent
end

struct NoteOn <: TrackEvent
    channel :: Int
    pitch :: Int
    velocity :: Int
end
NoteOn(ev::MIDIEvent) =
    if ev.data[2] == 0x00
        NoteOff(ev)
    else
        NoteOn(ev.status & 0x0F, ev.data[1], ev.data[2])
    end

struct NoteOff <: TrackEvent
    channel :: Int
    pitch :: Int
    velocity :: Int
end
NoteOff(ev::MIDIEvent) = NoteOff(ev.status & 0x0F, ev.data[1], ev.data[2])

struct TempoChangeME <: TrackEvent
    micro_per_quarter :: Int
end
TempoChangeME(ev::MetaEvent) = begin
    # this reinterpret should not work according to the julia doc, might break
    TempoChangeME(ntoh(reinterpret(UInt32, [0x00, ev.data...])[1]))
end

struct TimeSig
    num :: Int
    denom :: Int
end

struct TimeSignatureME <: TrackEvent
    sig :: TimeSig
    metroticks :: Int
    beatlen_in_32 :: Int
end
TimeSignatureME(ev::MetaEvent) =
    TimeSignatureME(TimeSig(ev.data[1], 2^ev.data[2]), ev.data[3], ev.data[4])

struct KeySig
    sharps :: Int
    major :: Bool
end

struct KeySignatureME <: TrackEvent
    sig :: KeySig
end
KeySignatureME(ev::MetaEvent) = begin
    KeySignatureME(KeySig(ev.data[1], ev.data[2]==0))
end

# Conversion to more informative event types
# ==========================================

uptype(x::TrackEvent) = UpEvent(x.dT, x)

function uptype(ev::MIDIEvent)
    inner = if ev.status & 0xF0 == 0x80
        NoteOff(ev)
    elseif ev.status & 0xF0 == 0x90
        NoteOn(ev)
    else
        ev
    end
    UpEvent(ev.dT, inner)
end

function uptype(ev::MetaEvent)
    inner = if ev.metatype == 0x51
        TempoChangeME(ev)
    elseif ev.metatype == 0x58
        TimeSignatureME(ev)
    elseif ev.metatype == 0x59
        KeySignatureME(ev)
    else
        ev
    end
    UpEvent(ev.dT, inner)
end

function uptype(track::MIDI.MIDITrack)
    map(uptype, track.events)
end

# Conversion to note list/matrix representations
# ==========

# turns an uptyped `MIDITrack` into a vector of tuples
# (tracknum, keysig, event) where keysig is the current
# key signature according to `KeySignatureME` events in the input.
function preparetrack(track::Vector{UpEvent}, tracknum::Int)
    out = Vector{Tuple{Int,KeySig,UpEvent}}(
        # as long as input but without KeySignatureME events
        count(ev -> !isa(ev.ev,KeySignatureME), track)
    )
    i = 1
    key = KeySig(0, true) # default: C major
    for ev in track
        if isa(ev.ev, KeySignatureME)
            # update key signature
            key = ev.ev.sig
        else
            # add event to output
            out[i] = (tracknum, key, ev)
            i += 1
        end
    end
    out
end

# merges a vector of prepared tracks, keeping the event onsets in order
function mergetracks(tracks::Vector{Vector{Tuple{Int,KeySig,UpEvent}}})
    # filter empty tracks
    filter!(!isempty, tracks)
    total = sum(map(length, tracks))
    out = Vector{Tuple{Int,KeySig,UpEvent}}(total)
    is = ones(Int, total)
    # tracklist = collect(enumerate(tracks))

    function besttrack()
        n = length(tracks)
        if n==1
            return 1
        else
            minj = 1
            mintime = tracks[minj][is[minj]][3].dT::Int
            for j in 2:length(tracks)
                time = tracks[j][is[j]][3].dT::Int
                if  time < mintime
                    minj = j
                    mintime = time
                end
            end
            return minj
        end
    end
    
    for iout in 1:total
        best = besttrack()
        out[iout] = tracks[best][is[best]]
        is[best] += 1
        if is[best] > length(tracks[best])
            deleteat!(tracks, best)
            deleteat!(is, best)
            #tracklist = collect(enumerate(tracks))
        end
    end
    out
end

function bigeventlist(midi::MIDIFile)
    map(MIDI.toabsolutetime!, midi.tracks)
    uptracks = map(uptype, midi.tracks)
    preptracks = [preparetrack(track, i) for (i, track) in enumerate(uptracks)]
    evs = mergetracks(preptracks)
end

# TODO: output datastream instead of dataframe?
# TODO: different ways of handling orphans
"""
    midifilenotes(file; warnings=false, overlaps=:queue, orphans=:skip)

Reads a midi file and returns a `DataFrame` with one row per note.
On- and offset times are given in ticks, whole notes, and seconds.
The data frame has the following columns:
- onset_ticks (Int)
- offset_ticks (Int)
- onset_wholes (Rational{Int})
- offset_wholes (Rational{Int})
- onset_secs (Rational{Int})
- offset_secs (Rational{Int})
- pitch (MidiPitch)
- velocity (Int)
- channel (Int)
- track (Int)
- key_sharps (Int)
- key_major (Bool)

If `warnings` is `true`, warnings about encoding errors will be displayed.
If two notes overlap on the same channel and track
(e.g. two ons, then two offs for the same pitch)
`overlaps` provides the strategy for interpreting the sequence of on and off events:
- `:queue` matches ons and offs in a FIFO manner (first on to first off).
- `:stack` matches ons and offs in a LIFO manner (first on to last off).

`orphans` determines what happens to on and off events without counterpart.
Currently, its value is ignored and orphan events are always skipped.
"""
function midifilenotes(file::AbstractString; warnings=false, overlaps=:queue, orphans=:skip)
    if overlaps == :queue
        takenote! = shift!
    elseif overlaps == :stack
        takenote! = pop!
    else
        error("Invalid value for overlaps: ", string(overlaps))
    end

    midifile = readMIDIfile(file)
    evs = bigeventlist(midifile)
    
    # estimate total > real total
    total = min(count(e->isa(e[3].ev, NoteOn), evs), count(e->isa(e[3].ev, NoteOff), evs))

    onset_ticks = sizehint!(Int[], total)
    offset_ticks = sizehint!(Int[], total)
    onset_wholes = sizehint!(Rational{Int}[], total)
    offset_wholes = sizehint!(Rational{Int}[], total)
    onset_secs = sizehint!(Float64[], total)
    offset_secs = sizehint!(Float64[], total)
    pitch = sizehint!(MidiPitch[], total)
    velocity = sizehint!(Int[], total)
    track = sizehint!(Int[], total)
    channel = sizehint!(Int[], total)
    key_sharps = sizehint!(Int[], total)
    key_major = sizehint!(Bool[], total)
    onset_bar = sizehint!(Int[], total)
    onset_beat = sizehint!(Int[], total)
    onset_subbeat = sizehint!(Rational{Int}[], total)
    # track, channel, pitch -> onset_ticks, onset_wholes, onset_secs, velocity, keysig
    OnsVal = Tuple{Int,SimpleRatio{Int},Float64,Int,KeySig,Int,Int,Rational{Int}}
    ons = Dict{Tuple{Int,Int,Int},
               Union{Vector{OnsVal},OnsVal}}()
    # ons = Dict{Tuple{Int,Int,Int}, Tuple{Int,SimpleRatio{Int},Float64,Int,KeySig}}()

    # tempo settings
    tdiv = PulsesPerQuarter(midifile.tpq) # time division
    # TODO: check for TicksPerSecond case

    # conversion coefficients
    # ticks -> beat or time is linear (but not proportional after a tempo change)
    # => y = a1*ticks + a0
    # coeffs: (a0, a1)
    ratios = timeratios(tdiv, 500_000) # default tempo: 120qpm
    wcoeffs = (SimpleRatio(0,1), ratios[1])      # whole notes
    scoeffs = (0.0, ratios[2])      # seconds
    totime(coeffs, x) = coprime(x*coeffs[2] + coeffs[1])
    # a0 = y - a1*ticks
    newcoeffs(ticks, time, ratio) = (coprime(time - ratio * ticks), ratio)

    baroff = 0//1
    barref = 0
    barlen = 1//1
    beatlen = 1//4

    # process each event. notes are added, timing events change status
    for (trackid, keysig, ev) in evs
        # current time in all units
        nowt = ev.dT
        noww = totime(wcoeffs, nowt)
        nows = totime(scoeffs, nowt)
        relbar = (noww - baroff) / barlen
        nowbar = barref + floor(Int, relbar)
        inbar = relbar % 1
        nowbeat = floor(Int, inbar / beatlen)
        nowsubb = (inbar / beatlen) % 1

        if isa(ev.ev,TempoChangeME)
            # tempo change: update conversion coefficients
            ratios = timeratios(tdiv, ev.ev.micro_per_quarter)
            wcoeffs = newcoeffs(nowt, noww, ratios[1])
            scoeffs = newcoeffs(nowt, nows, ratios[2])
        elseif isa(ev.ev,TimeSignatureME)
            baroff = noww
            barref = inbar == 0 ? nowbar : nowbar + 1 # allows incomplete bars
            barlen = ev.ev.sig.num // ev.ev.sig.denom
            beatlen = 1 // ev.ev.sig.denom
        elseif isa(ev.ev,NoteOn)
            # note on: register in `ons`
            notek = (trackid, ev.ev.channel, ev.ev.pitch)
            notev = (nowt, noww, nows, ev.ev.velocity, keysig, nowbar, nowbeat, nowsubb)
            if !haskey(ons, notek)
                ons[notek] = notev
            elseif isa(ons[notek], Tuple)
                ons[notek] = [ons[notek], notev]
            else
                if warnings && !isempty(ons[notek])
                    warn("note is already on: ", notek)
                end
                push!(ons[notek], notev)
            end
        elseif isa(ev.ev, NoteOff)
            # note off: add to output and delete from `ons`
            notek = (trackid, ev.ev.channel, ev.ev.pitch)
            if haskey(ons, notek)# && !isempty(ons[notek])
                if isa(ons[notek], Tuple)
                    on = pop!(ons, notek)
                else
                    on = takenote!(ons[notek])
                end
                push!(onset_ticks, on[1])
                push!(offset_ticks, nowt)
                push!(onset_wholes, on[2])
                push!(offset_wholes, noww)
                push!(onset_secs, on[3])
                push!(offset_secs, nows)
                push!(pitch, midi(ev.ev.pitch))
                push!(velocity, on[4])
                push!(track, trackid)
                push!(channel, ev.ev.channel)
                push!(key_sharps, on[5].sharps)
                push!(key_major, on[5].major)
                push!(onset_bar, on[6])
                push!(onset_beat, on[7])
                push!(onset_subbeat, on[8])
            elseif warnings
                warn("orphan note-off: ", notek)
            end
        end
    end

    out = DataFrame(
        onset_ticks=onset_ticks,
        offset_ticks=offset_ticks,
        onset_wholes=onset_wholes,
        offset_wholes=offset_wholes,
        onset_secs=onset_secs,
        offset_secs=offset_secs,
        pitch=pitch,
        velocity=velocity,
        track=track,
        channel=channel,
        key_sharps=key_sharps,
        key_major=key_major,
        onset_bar=onset_bar,
        onset_beat=onset_beat,
        onset_subbeat=onset_subbeat
    )
    sort!(out, [:onset_ticks, :track, :channel])
    out
end

end # module
