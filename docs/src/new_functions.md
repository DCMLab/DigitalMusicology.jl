# Digital Musicology Julia Library extension

The purpose of this extension is to add functionalities from the Matlab  MidiToolBox  to the DigitalMusicology library and generalize them to support data representations others than MIDI.

Midi notes are represented in Matlab with note matrices. Here, midi files are converted to iterators of Notes and then they can be passed to the functions. First, the midi file is converted to a dataframe with the function midifilenotes() (already present in the library). This dataframe contains all the information from the midi file. We can then iterate over it with an Itermidi iterator.

1. 1Iterating through Notes
  1. 1.1Itermidi

struct Itermidi

    midiframe :: DataFrame

    timetype :: String
end

When instantiating the Itermidi, we must provide the DataFrame containing the notes and the type of the temporal informations. &#39;timetype&#39; can take the following values: "wholes", ticks and "secs". When iterated, Itermidi returns a Note. As most of the functions over an Itermidi use the time unit of the notes, the user must be careful when using temporal informations ( in function arguments for example).

1.
  1. 1.2notesequence(notes,n :: Int64)

This function returns an iterator over sequences of n consecutive notes. It works like grams() but takes iterators as argument, it can also handle iterators of other types than Itermidi. When iterated, notesequence returns an Array containing the sequence.

1.
  1. 1.3Example

frame1 = midifilenotes("sample1.mid")  #sample1 contains 4 notes with pitches 48,50,52,55

iter1 = Itermidi(frame1,"wholes")

julia\&gt;  for n in notesequence(iter1,2) println(n) end

TimedNote{MidiPitch,Rational{Int64}}[Note<0//1 - 1//4>(48), Note<1//4 - 1//2>(50)]

TimedNote{MidiPitch,Rational{Int64}}[Note<1//4-1//2>(50), Note<1//2-3//4>(52)]

TimedNote{MidiPitch,Rational{Int64}}[Note<1//2 - 3//4>(52), Note<3//4 - 1//1>(55)]

1. 2Distributions

Various distributions can be computed from an iterator of Notes. They are represented by a dictionary (Dict{K,V}) where the key is a feature of the note and the value is its proportion in the sample.

1.
  1. 2.1dist(data,feature = e->e, func = e -> 1, normalize :: Bool = true)

Dist() is the function from which all other distribution functions are constructed.

Arguments:

- data: iterator over the sample
- feature: function extracting the feature from each element of the sample. By default, the element itself
- func : function weighting each element. By default, its occurrence
- normalize: if true, all values of the dictionary are divided by their total sum (except if it equals zero)

1.
  1. 2.2Distributions from MidiToolBox

- pcdist1(notes,weight = e ->1,normalize :: Bool = true)

computes the pitchclass distribution. We can weight the notes by their occurencies (by default) or for example by their duration: weight = e-> duration(e)

- pcdist2(notes,weight = (e1,e2)-> 1,normalize :: Bool = true)

computes the second-order distribution. As for all the other second-order distributions, it requires a monophonic set of notes and the keys of the dictionary are tuples of pitches (p1,p2).

- durdist1(notes, weight = e->1,normalize :: Bool = true)

computes the duration distribution.

- durdist2(notes,weight = (e1,e2)-> 1,normalize :: Bool = true)

computes the second-order duration distribution.

- ivdist1(notes,weight = (e1,e2)->1,normalize :: Bool = true)

computes the interval distribution._

- _ivdist2(notes, weight = (e1,e2,e3)->1,normalize :: Bool = true)

computes the second-order interval distribution.

1. 3 Melcontour

melcontour(notes, res,func)

This function computes the melodic contour of a monophonic set of notes identically as the melcontour function of the MidiToolBox :

lframe = midifilenotes("test/laksin.mid")

liter = Itermidi(lframe,"wholes")

plot(melcontour(liter,1//4,e->(pitch(e)).pitch))


The function returns an array containing the points of the contour. The first element of the array is the first note.  The temporal distance between the points is given by res. Each point takes the value of the closest note with onset smaller than indexOfThePoint\*res. The last element of the array is not computed with the onset of the last note but with its offset. 'func' is the function converting notes to real number, it must return a Float64 value. For the melodic contour, &#39;func&#39; returns the midi pitch but we can plot other features like duration:

plot(melcontour(liter,1//4, e->(duration(e))))

 

Once the melodic contour is computed, we can consider it as a signal or vector and apply statistical functions.

1.
  1. 3.1 acorr(notes,res,func,pairlag :: Bool = false)

acorr() computes the autocorrelation of the notes using their melodic contour. It returns an array containing the coefficients. The first element is the autocorrelation with zero lag (hence always =1). The second is with one-lag etc. If pairlag is true, the elements of the array are the coefficient paired with (indexOfCoefficient-1)\*res.

1.
  1.
    1. 3.1.1Example

plot(acorr(liter,1//4,e->(pitch(e)).pitch,true))



1. 4 Other Functions

- midipitchname(p :: MidiPitch)

Returns the literal name of the midi pitch eg.  midipitchname(midi(71)) = "B4"

- quantize(note,tresh = 1//8 )

Quantize the onset and the offset of the note on a temporal grid with resolution 'thresh'

- ismonophonic(notes,overlap = 0.1)

Verify if the iterator of notes is monophonic with a tolerance given by 'overlap'

- znnotes(notes,feature)

Used to be a helper function then forsaken but could be one time useful.  Znnotes returns an iterator over a zero-normalized feature of the notes

- duraccent(note,tau :: Float64 = 0.5, accentIndex :: Float64 = 2.0)

Same as the duraccent function in MidiToolBox. MidiToolBox description:

Function returns duration accent of the events (Parncutt, 1994, p. 430-431) where tau represents

saturation duration, which is proportional to the duration of the echoic store. Accent index covers the

minimum discriminable duration. The difference between Parncutt's model and this implementation is

on the IOI (inter-onset-intervals).

Input arguments:

DUR = vector of note duration in

seconds

TAU (optional) = saturation duration

(default 0.5)

ACCENT\_INDEX (optional) =

minimum discriminable duration (default 2)

- mobility(notes)

Same as the mobility function in MidiToolBox. MidiToolBox description:

Mobility describes why melodies change direction after large skips

by simply observing that they would otherwise run out of the

comfortable melodic range. It uses lag-one autocorrelation between

successive pitch heights (Hippel, 2000).

- melaccent(notes, ivcomp = (e1,e2)-> (e1 > e2) ? 1 : ((e1 == e2) ? 0 : -1 ))

Same as melaccent in in MidiToolBox. But as the function compares pitches, it needs a comparator

MidiToolBox description:

Calculates melodic accent salience according to Thomassen&#39;s model. This model assigns melodic

accents according to the possible melodic contours arising in 3-pitch windows. Accent values vary

between 0 (no salience) and 1 (maximum salience).

- keysom(notes)

Same as the keysom function from MidiToolBox. The heatmap seems correct but I don&#39;t know if the values are too...

 MidiToolBox Description :

Creates a pseudocolor map of the pitch class distribution of NMAT projected onto a self-organizing map trained

with the Krumhansl-Kessler profiles.

 