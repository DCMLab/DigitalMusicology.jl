module External

using DigitalMusicology

export musescore

musescore(id, corpus = get_corpus()) = begin
    file = piece_path(id, "m", ".mid", corpus)
    run(`musescore $file`)
end

end # module
