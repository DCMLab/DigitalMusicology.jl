module PitchOps

using DigitalMusicology

export pc, allpcs, transposeby, transposeto, midipitchname

"Turn a pitch (or pitch collection) into a pitch class (collection)"
function pc end

pc(pitch::MidiPitch) = midi(mod(pitch.pitch, 12))

"""
    allpcs(P)

Returns a list of all pitch classes of pitch type P.
"""
function allpcs end

allpcs(::Type{MidiPitch}) = midis(0:11)

"Transpose a pitch (collection) by some directed interval."
function transposeby end

transposeby(pitch::P, interval::P) where {P <: Pitch} = pitch+interval

"Transpose a pitch (collection) to a new reference point."
function transposeto end

transposeto(pitch::P, newref::P) where {P <: Pitch} = newref


"""
    midiPitchName(p :: MidiPitch)

return the name of the given MidiPitch
midi pitches must take values between 21 and 108
"""
function midipitchname(p :: MidiPitch)
  if(p.pitch < 21 || p.pitch > 108)
    throw(ArgumentError("pitch out of bounds"))
  end
  miditable = ["C","C#","D","D#","E","F","F#","G","G#","A","A#","B"]
  return string(miditable[mod(p.pitch,12)+1],floor(Int,(p.pitch)/12)-1)
end
end # module
