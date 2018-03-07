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
    end
end
