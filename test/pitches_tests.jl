@testset "pitches" begin
    @test isbitstype(MidiPitch)
    @test hash(midi(12)) == hash(midi(12))

    @test midi(12) + midi(3) == midi(15)
    @test midi(2) - midi(3) == midi(-1)
    @test zero(midi(3)) == midi(0)
    @test zero(MidiPitch) == midi(0)

    @test pc(midi(12)) == midi(0)
    @test pc(midi(3)) == midi(3)
    @test pc(midi(-1)) == midi(11)
    @test pc(midi(-13)) == midi(11)

    @test transposeby(midi(3), midi(4)) == midi(7)
    @test transposeby(midi(3), midi(-4)) == midi(-1)
    @test transposeto(midi(8), midi(6)) == midi(6)
end
