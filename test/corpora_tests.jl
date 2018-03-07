struct MyTestCorpus <: Corpus end

@testset "Corpora Tests" begin
    @testset "Current Corpus Tests" begin
        @test_throws ErrorException get_corpus()
        @test set_corpus(MyTestCorpus()) == MyTestCorpus()
        @test get_corpus() == MyTestCorpus()
        @test unset_corpus() == NoCorpus()
        @test_throws ErrorException get_corpus() == NoCorpus()
    end

    @testset "LACCorpus Tests" begin
        use_lac("fake_lac/")
        @test isa(get_corpus(), DigitalMusicology.Corpora.LAC.LACCorpus)

        @test collect(all_pieces()) == ["0/ursatz"]
        @test collect(all_pieces("0/")) == ["0/ursatz"]
        @test collect(all_pieces(top_dir())) == collect(all_pieces())

        @test dirs() == Set(["0/"])
        @test isempty(dirs("0/"))
        @test isempty(pieces("./"))
        @test pieces("0/") == Set(["0/ursatz"])
        @test ls() == ["0/"]
        
    end
end
