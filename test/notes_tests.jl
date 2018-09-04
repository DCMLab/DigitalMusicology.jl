using DigitalMusicology
using Base.Iterators
using StatsBase
using Test


# dataframes for tests
lframe = midifilenotes("laksin.mid")
nullframe = midifilenotes("empty.mid")
mframe = midifilenotes("multich.mid")
oneframe = midifilenotes("onenote.mid")
sframe = midifilenotes("sample1.mid")

@testset "Itermidi" begin
    @test iterate(Itermidi(nullframe,"secs")) == nothing

    for s in ["secs","wholes","ticks"]
        i = 1
        iter = Itermidi(lframe,s)
        for n  in iter
            @test onset(n) == lframe[i,Symbol("onset_",s)]     # all notes and all time types
            @test offset(n) == lframe[i,Symbol("offset_",s)]
            @test pitch(n) == lframe[i,:pitch]
            i +=1
        end
    end
end


@testset "ismonophonic" begin

    eiter = Itermidi(nullframe,"secs")
    @test ismonophonic(eiter) == true

    for s in ["secs","wholes","ticks"]
        liter = Itermidi(lframe,s)
        @test ismonophonic(liter, 0) == true
    end

    for s in [("secs",0.1),("wholes",1//4),("ticks",100)]
        miter = Itermidi(mframe,s[1])
        @test ismonophonic(miter,0) == false
        @test ismonophonic(miter,s[2]) == false
    end

    iter = Itermidi(lframe,"secs")
    @test_throws ArgumentError ismonophonic(iter,-0.1)  #fails on negative overlap
end

@testset "quantize" begin
    znote = TimedNote(midi(0),0,0)
    note1 = TimedNote(midi(0),0,1)
    note2 = TimedNote(midi(0),0.,0.9)
    note3 = TimedNote(midi(0),0.,0.7)
    note4 = TimedNote(midi(0),28.28,41.41)
    @test onset(quantize(znote,0.5)) ==  0 && offset(quantize(znote,0.5)) ==  0
    @test onset(quantize(note1,1)) ==  0 && offset(quantize(note1,1)) ==  1
    @test onset(quantize(note2,0.5)) ==  0 && offset(quantize(note2,0.5)) ==  1
    @test onset(quantize(note3,0.5)) ==  0 && offset(quantize(note3,0.5)) ==  0.5
    #@test onset(quantize(note4,0.1)) == 28.3 && offset(quantize(note4,0.1)) ==  41.4   #WANRING with thresholds like 0.1, return non-exactly rounded values like 1.000005
end
