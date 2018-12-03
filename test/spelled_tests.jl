@testset "spelled" begin

    @testset "accidentials" begin
        @test Acc("##b#") == Acc(2)
        @test string(flat) == "b"
        @test sharp == Acc("#")
        @test flat == Acc("b")
    end

    @testset "spelled intervals" begin
        @test SpelledInterval.(split("1 2 b3 4 5 b6 b7")) .|> chromatic == [0,2,3,5,7,8,10]
        @test SpelledInterval("3") + SpelledInterval("b3") == SpelledInterval("5")
        @test iszero(SpelledInterval("bb43") - SpelledInterval("bb43"))
        @test string(SpelledInterval("-b3")) == "-b3"
        @test string(SpelledInterval("b3")) == "b3"
        @test chromatic(SpelledInterval("10")) == 16
    end

    @testset "spelled pitches" begin
        @test p"Eb4" + i"3" == p"G4"
        @test p"Eb4" - i"4" == p"Bb3"
        @test flat(p"C4")     == p"Cb4"
        @test chromatic(p"C4") == 4 * 12
        @test diatonic(p"C4")  == 4 * 7
        @test chromatic(p"F4") == 4 * 12 + 5
        @test diatonic(p"F4")  == 4 * 7  + 3
        @test sharp(p"F-1")   == p"F#-1"
        @test p"F#3" - p"Db3" == i"#3"
        @test p"F#2" - p"D2"  == i"3"
        @test p"F4"  - p"D4"  == i"b3"
        @test p"F4"  - p"D#4" == i"bb3"

        for tone in DigitalMusicology.Spelled.natural_tones
            for acc in [["#" ^ k for k in 1:10]; ["b" ^ k for k in 1:10]]
                @test string(SpelledPitch(string(tone, acc, 4))) == string(tone, acc, 4)
            end
        end
    end

    @testset "spelled interval classes" begin
        @test flat(ic"3") == ic"b3"
        @test diatonic(ic"b7") == ModInt{7}(6)
        @test chromatic(ic"b7") == ModInt{12}(10)
        @test SpelledIC.(split("1 2 b3 4 5 b6 b7")) .|> chromatic == ModInt{12}.([0,2,3,5,7,8,10])
        @test SpelledIC("3") + SpelledIC("b3") == SpelledIC("5")
        @test ic"5" + ic"b5" == ic"b2"
    end

    @testset "spelled pitch classes" begin
        @test flat(pc"C")  == pc"Cb"
        @test sharp(pc"F") == pc"F#"
        @test pc"F#" - pc"Db" == ic"#3"
        @test pc"F#" - pc"D"  == ic"3"
        @test pc"F"  - pc"D"  == ic"b3"
        @test pc"F"  - pc"D#" == ic"bb3"

        for tone in DigitalMusicology.Spelled.natural_tones
            for acc in [["#" ^ k for k in 1:10]; ["b" ^ k for k in 1:10]]
                @test string(SpelledPC(string(tone, acc))) == string(tone, acc)
            end
        end
    end

    @testset "modes" begin
        @test ics(Major)[3] == ic"3"
        @test ics(Minor)[3] == ic"b3"
    end

    @testset "spelled keys" begin
        k = key"cb"
        @test string(k) == "cb"
        @test mode(k) == Minor
        @test root(k) == pc"Cb"
        @test pcs(SpelledKey(pc"Bb", Major)) == SpelledPC.(split("Bb C D Eb F G A"))
        @test pcs(SpelledKey(pc"A", Major)) == SpelledPC.(split("A B C# D E F# G#"))
        @test root(SpelledKey(pc"G", Minor) + ic"5") == pc"D"
        @test root(SpelledKey(pc"G", Minor) - ic"5") == pc"C"
    end

    @testset "scale degrees" begin
        @test string(sd"II_{Db}") == "II_{Db}"

        @test key(modulate(ScaleDegree("III", SpelledKey(pc"Eb", Major)))) == SpelledKey(pc"G", Minor)
        @test key(modulate(ScaleDegree("VII", SpelledKey(pc"E", Minor)))) == SpelledKey(pc"D", Major)

        k  = SpelledKey(pc"F", Minor)
        pc = pc"Ab"
        sd = ScaleDegree("III", k)
        @test SpelledPC(sd) == pc
        @test ScaleDegree(pc, k) == sd
        @test string(sd) == "III_{f}"
        @test chromatic(sd) == ModInt{12}(8)
    end

end
