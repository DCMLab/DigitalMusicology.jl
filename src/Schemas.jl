module Schemas

import Base: ==, hash, collect, length, show, size, getindex
import DigitalMusicology.PitchOps: pc, transposeby, transposeto
import DigitalMusicology.PitchCollections: refpitch
using DigitalMusicology

export FlatSchema, stages, nstages, nvoices
export matchschema

# Schema Interface
# ================

"""
    stages(schema)

Returns a the stages of `schema`. 
"""
function stages end

"""
    nstages(schema)

Returns the number of stages in `schema`.
"""
function nstages end

"""
    nvoices(schema)

Returns the number of voices in `schema`.
"""
function nvoices end

"""
    matchschema(schema, gram)

Returns all reference pitch classes on which `gram` matches `schema`.
`gram` should be a vector of pitch vectors in voice order (highest to lowest).
"""
function matchschema end

"""
    schema_matches_from(schema, gram, ref)

Tests whether a schema based on the pitch `ref` matches
`gram`, which is a vector of pitch vectors in voice order (highest to lowest).
"""
function schema_matches_from end


# Flat Schema - the most simple representation of a schema
# ========================================================

"""
    FlatSchema(pitches)

Represents a schema as a matrix of pitch classes:
Rows are schema stages, columns are descending voices.
A three-voiced schema with four stages is then represented by a 4x3 matrix.
"""
struct FlatSchema{P} <: PitchCollection{P}
    pitches :: Array{P,2}

    FlatSchema(pitches::Array{P,2}) where P =
        new{P}(pc.(pitches))
end

### Schema interface implementations

getstage(fs::FlatSchema{P}, stage::Int) where P = view(fs.pitches, stage, :)

(stages(fs::FlatSchema{P}) :: Vector{Vector{P}}) where P =
    [getstage(fs, i) for i in size(fs.pitches, 1)]

nstages(fs::FlatSchema) = size(fs.pitches, 1)

nvoices(fs::FlatSchema) = size(fs.pitches, 2)

### Base implementations

==(fs1::FlatSchema{P}, fs2::FlatSchema{P}) where P =
    fs1.pitches == fs2.pitches

hash(fs::FlatSchema, x::UInt) = hash(fs.pitches, x)

size(fs::FlatSchema) = size(fs.pitches)
size(fs::FlatSchema, dims...) = size(fs.pitches, dims...)

getindex(fs::FlatSchema, i, j) = fs.pitches[i,j]

collect(fs::FlatSchema) = fs.pitches

show(io::IO, fs::FlatSchema) = write(io, "FlatSchema:", string(fs.pitches))

function show(io::IO, ::MIME"text/plain", fs::FlatSchema)
    ps = fs.pitches
    write(io, "Schema: ",
          string(size(ps, 1)), " stages, ",
          string(size(ps, 2)), " voices\n")
    for ri in 1:size(ps, 1)
        write(io, string(ri), ": ", join(fs.pitches[ri,:], " "), "\n")
    end
end

### Schema Matching

function schema_matches_from(fs::FlatSchema{P}, gram::Vector{Vector{P}}, ref::P) where P
    nv = nvoices(fs)
    
    # check all stages
    all(1:nstages(fs)) do s
        #check all voices
        v = 1
        for pitch in gram[s]
            # if current voice is matched...
            if pc(pitch) == pc(fs[s,v] + ref)
                v += 1 # go to next voice
                if v > nv break end
            end
        end
        v > nv # all found?
    end
end

    # test compatibility
    if nstages(fs) != length(gram) return P[] end
    if any(g -> length(g) < nvoices(fs), gram) return P[] end
    
    # try all pcs as reference
    filter(ref -> schema_matches_from(fs, gram, ref), allpcs(P))
end

# match schemas on slice grams
#matchschema(fs::FlatSchema{P}, gram::Vector{Slice{N,Vector{P}}}) where {N,P} =
#    matchschema(fs, unwrapslices(gram))

# match schemas on unsims
matchschema(fs::FlatSchema{P}, gram) where P =
    matchschema(fs, map(schemainst_stagepitches, gram))
## Example

#@midi prinner1 = FlatSchema([9 5; 7 4; 5 2; 4 0])

end # module Schemas
