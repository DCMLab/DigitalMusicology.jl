@testset "Grams" begin

    @testset "Grams and Scapes" begin
        @test grams([1,2,3,4,5], 3) == [[1,2,3], [2,3,4], [3,4,5]]
        @test scapes([1,2,3]) == [[[1], [2], [3]],
                                  [[1, 2], [2, 3]],
                                  [[1, 2, 3]]]
    end

    @testset "Skipgrams (Arrays)" begin
        @test DigitalMusicology.Grams.skipgrams_general(
            1:5, 4.0, 2,
            (x1, x2) -> x2-x1-1,
            (x1, x2) -> iseven(x2-x1)) ==
                [[1,3], [2,4], [1,5], [3,5]]
        @test DigitalMusicology.Grams.skipgramsv(1:5, 2, 2) ==
            [[1,2], [1,3], [2,3], [1,4], [2,4], [3,4], [2,5], [3,5], [4,5]]
    end

    @testset "Skipgrams (Iterators)" begin
        @test collect(skipgrams_itr(1:5, 4.0, 2,
                                    (x1, x2) -> x2-x1-1,
                                    (x1, x2) -> iseven(x2-x1))) ==
                                        [[1,3], [2,4], [1,5], [3,5]]
        @test collect(skipgrams(1:5, 2, 2)) ==
            [[1,2], [1,3], [2,3], [1,4], [2,4], [3,4], [2,5], [3,5], [4,5]]
    end

    @testset "Skipgrams (Channels)" begin
        @test collect(DigitalMusicology.Grams.skipgrams_channel(
            1:5, 4.0, 2,
            (x1, x2) -> x2-x1-1,
            (x1, x2) -> iseven(x2-x1))) ==
                [[1,3], [2,4], [1,5], [3,5]]
        @test collect(DigitalMusicology.Grams.skipgramsc(1:5, 2, 2)) ==
            [[1,2], [1,3], [2,3], [1,4], [2,4], [3,4], [2,5], [3,5], [4,5]]
    end
end
