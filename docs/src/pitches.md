# Pitches and Pitch Classes

## Pitches and Pitch Classes

Pitches and Pitch classes are represented by special types,
which allows to define and specialize operations
that should work on all kinds of pitches and pitch classes.

Pitches and Pitch classes usually come as a pair
(one pitch type and a corresponding pitch class type).
Operations that work on pitches should also work on pitch classes,
so that pitch classes can be thought of as a special case of pitches.
As a result, we get the following type hierarchy:

```julia
abstract type Pitch end
abstract type PitchClass <: end
```

All pitch and pitch class types should be subtypes of `Pitch` or `PitchClass`, respectively.

Generally, pitches (and pitch classes) represent *intervals* instead of abstract pitches.
This way, *adding* or *substracting* two pitches (intervals) has a meaningful interpretation,
while absolute pitches may still be represented by interpreting intervals as relative to
a reference pitch (origin).
The space of intervals (and associated absolute pitches) thus forms a *module* over integers,
which is like a vector space but you can do scalar multiplication only with integers.

## Operations on Pitches

As mentioned above, pitches (interpreted as intervals) form a *module*, so all operations
in modules should be supported.
In the following lists, lowercase variables stand for pitch(class) values,
while uppercase variables stand for pitch(class) types.

- addition: `p1 + p2`
- substraction: `p1 - p2`
- invert: `-p`
- zero: `Base.zero(P)`
- scalar multiplication: `p * Int` or `Int * p`

Furthermore, some other functions are convenient on pitches:

- orientation: `Base.sign(p)`.
  This should indicate, whether the interval goes up or down.
  For pitch classes (which represent two intervals, one up and its inverse down),
  the direction of the shortest way is indicated.
- converting to Midi: `tomidi(p)`
- size of octave: `octave(P)`

```@docs
tomidi
```

```@docs
octave
```

## Converting between Pitches and Pitch Classes

The following operations are used to convert between pitches and pitch classes

- pitch to pitch class: `pc(p)`.
- pitch class to pitch: `embed(p, [oct])`.
  This will embed the pitch class into a default octave,
  which can be modified with `oct` (`Int`).
- get the pitch class type corresponding to a pitch type:
  `pitchclasstype(P)`
- get the pitch type corresponding to a pitch class type:
  `pitchtype(P)`

If you give a pitch class to `pc` or a non-class to `embed`,
the original input is returned.
The same holds for `pitchtype` and `pitchclasstype`.

## Other Useful Methods

Pitch (class) types should generally implement a few useful methods:

- `Base.==` and `Base.isless` for comparision
- `Base.hash` for hashing
- `Base.show` for printing
- `Base.convert` where appropriate
