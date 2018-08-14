using Random

@testset "Pitch Collections" begin
    pitches = map(midi, [3, -13, -1, 3, 5, 17])
    inc(x) = x+midi(1)

    @testset "PitchBag" begin
        pb = pbag(pitches)
        @test pb == pbag(pitches)
        @test pb == pbag(shuffle(pitches))
        @test hash(pb) == hash(pbag(shuffle(pitches)))
        @test sort(collect(pb)) == sort(pitches)
        @test length(pb) == 6
        @test map(inc, pb) == pbag(map(inc, pitches))
        @test transposeby(pb, midi(1)) == pbag(map(inc, pitches))
        @test transposeto(pb, midi(0)) == transposeby(pb, midi(13))
        @test pc(pb) == pcbag(pitches)
    end

    @testset "PitchClassBag" begin
        pb = pcbag(pitches)
        @test pb == pcbag(pitches)
        @test pb == pcbag(shuffle(pitches))
        @test pb == pcbag(map(p->p+midi(12), pitches))
        @test hash(pb) == hash(pcbag(shuffle(pitches)))
        @test sort(collect(pb)) == sort(map(pc, pitches))
        @test all(p -> midi(0)<=p<=midi(11), collect(pb))
        @test length(pb) == 6
        @test map(inc, pb) == pcbag(map(inc, pitches))
        @test transposeby(pb, midi(1)) == pcbag(map(inc, pitches))
        # @test transposeto(pb, midi(0)) == transposeby(pb, midi(-3))
        @test pc(pb) == pb
    end

    @testset "PitchSet" begin
        ps = pset(pitches)
        @test ps == pset(pitches)
        @test ps == pset(shuffle(pitches))
        @test hash(ps) == hash(pset(shuffle(pitches)))
        @test sort(collect(ps)) == sort(collect(Set(pitches)))
        @test length(ps) == 5
        @test map(inc, ps) == pset(map(inc, pitches))
        @test transposeby(ps, midi(1)) == pset(map(inc, pitches))
        @test pc(ps) == pcset(pitches)
    end

    @testset "PitchClassSet" begin
        ps = pcset(pitches)
        @test ps == pcset(pitches)
        @test ps == pcset(shuffle(pitches))
        @test ps == pcset(map(p->p+midi(12), pitches))
        @test hash(ps) == hash(pcset(shuffle(pitches)))
        @test sort(collect(ps)) == sort(collect(Set(map(pc, pitches))))
        @test all(p -> midi(0)<=p<=midi(11), collect(ps))
        @test length(ps) == 3
        @test map(inc, ps) == pcset(map(inc, pitches))
        @test transposeby(ps, midi(1)) == pcset(map(inc, pitches))
        @test pc(ps) == ps
    end

    @testset "FiguredPitch" begin
        fp = figuredp(pitches)
        @test bass(fp) == midi(-13)
        @test sort(collect(figures(fp))) == map(midi, [0, 4, 6])
        @test fp == figuredp(pitches)
        @test fp == figuredp(shuffle(pitches))
        @test hash(fp) == hash(figuredp(pitches))
        @test sort(collect(fp)) == map(midi, [3, 5, 11])
        @test length(fp) == 3
        @test transposeby(fp, midi(1)) == figuredp(map(inc, pitches))
        @test bass(transposeto(fp, midi(3))) == midi(3)
        @test figures(transposeto(fp, midi(3))) == figures(fp)
        @test pc(fp) == figuredpc(pitches)
    end

    @testset "FiguredPitch" begin
        fp = figuredpc(pitches)
        @test bass(fp) == midi(11)
        @test sort(collect(figures(fp))) == map(midi, [0, 4, 6])
        @test fp == figuredpc(pitches)
        @test fp == figuredpc(shuffle(pitches))
        @test hash(fp) == hash(figuredpc(pitches))
        @test sort(collect(fp)) == map(midi, [3, 5, 11])
        @test length(fp) == 3
        @test transposeby(fp, midi(1)) == figuredpc(map(inc, pitches))
        @test bass(transposeto(fp, midi(15))) == midi(3)
        @test figures(transposeto(fp, midi(3))) == figures(fp)
        @test pc(fp) == fp
    end
end
