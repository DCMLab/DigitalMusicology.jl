struct MyTestCorpus <: Corpus end

@testset "Corpora Tests" begin
    @testset "Current Corpus Tests" begin
        @test_throws ErrorException getcorpus()
        @test setcorpus(MyTestCorpus()) == MyTestCorpus()
        @test getcorpus() == MyTestCorpus()
        @test unsetcorpus() == NoCorpus()
        @test_throws ErrorException getcorpus() == NoCorpus()
    end

    @testset "LACCorpus Tests" begin
        uselac("fake_lac/")
        @test isa(getcorpus(), DigitalMusicology.Corpora.LAC.LACCorpus)

        @test collect(allpieces()) == ["0/ursatz"]
        @test collect(allpieces("0/")) == ["0/ursatz"]
        @test collect(allpieces(topdir())) == collect(allpieces())

        @test dirs() == Set(["0/"])
        @test isempty(dirs("0/"))
        @test isempty(pieces("./"))
        @test pieces("0/") == Set(["0/ursatz"])
        @test ls() == ["0/"]

        ns = getpiece("0/ursatz", :notes_secs)
        @test pitches(ns) == @midi [76, 48, 74, 55, 72, 48]
        @test map(onset, ns) == [0.0, 0.0, 1.0, 1.0, 2.0, 2.0]
        @test map(offset, ns) == [911/960, 911/960, 1871/960, 1871/960, 3743/960, 3743/960]

        nw = getpiece("0/ursatz", :notes_wholes)
        @test map(onset, nw) == [0//1, 0//1, 1//2, 1//2, 1//1, 1//1]
        @test map(offset, nw) == [911//1920, 911//1920, 1871//1920, 1871//1920, 3743//1920, 3743//1920]
    end
end
