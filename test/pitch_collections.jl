@testset "Pitch Collections" begin
    pitches = map(midi, [3, -13, -1, 3, 5, 17])
    inc(x) = x+midi(1)

    @testset "PitchBag" begin
        pb = p_bag(pitches)
        @test pb == p_bag(pitches)
        @test pb == p_bag(shuffle(pitches))
        @test hash(pb) == hash(p_bag(shuffle(pitches)))
        @test sort(collect(pb)) == sort(pitches)
        @test length(pb) == 6
        @test map(inc, pb) == p_bag(map(inc, pitches))
        @test transpose_by(pb, midi(1)) == p_bag(map(inc, pitches))
        @test transpose_to(pb, midi(0)) == transpose_by(pb, midi(13))
        @test pc(pb) == pc_bag(pitches)
    end

    @testset "PitchClassBag" begin
        pb = pc_bag(pitches)
        @test pb == pc_bag(pitches)
        @test pb == pc_bag(shuffle(pitches))
        @test pb == pc_bag(map(p->p+midi(12), pitches))
        @test hash(pb) == hash(pc_bag(shuffle(pitches)))
        @test sort(collect(pb)) == sort(map(pc, pitches))
        @test all(p -> midi(0)<=p<=midi(11), collect(pb))
        @test length(pb) == 6
        @test map(inc, pb) == pc_bag(map(inc, pitches))
        @test transpose_by(pb, midi(1)) == pc_bag(map(inc, pitches))
        # @test transpose_to(pb, midi(0)) == transpose_by(pb, midi(-3))
        @test pc(pb) == pb
    end

    @testset "PitchSet" begin
        ps = p_set(pitches)
        @test ps == p_set(pitches)
        @test ps == p_set(shuffle(pitches))
        @test hash(ps) == hash(p_set(shuffle(pitches)))
        @test sort(collect(ps)) == sort(collect(Set(pitches)))
        @test length(ps) == 5
        @test map(inc, ps) == p_set(map(inc, pitches))
        @test transpose_by(ps, midi(1)) == p_set(map(inc, pitches))
        @test pc(ps) == pc_set(pitches)
    end

    @testset "PitchClassSet" begin
        ps = pc_set(pitches)
        @test ps == pc_set(pitches)
        @test ps == pc_set(shuffle(pitches))
        @test ps == pc_set(map(p->p+midi(12), pitches))
        @test hash(ps) == hash(pc_set(shuffle(pitches)))
        @test sort(collect(ps)) == sort(collect(Set(map(pc, pitches))))
        @test all(p -> midi(0)<=p<=midi(11), collect(ps))
        @test length(ps) == 3
        @test map(inc, ps) == pc_set(map(inc, pitches))
        @test transpose_by(ps, midi(1)) == pc_set(map(inc, pitches))
        @test pc(ps) == ps
    end

    @testset "FiguredPitch" begin
        fp = figured_p(pitches)
        @test bass(fp) == midi(-13)
        @test sort(collect(figures(fp))) == map(midi, [0, 4, 6])
        @test fp == figured_p(pitches)
        @test fp == figured_p(shuffle(pitches))
        @test hash(fp) == hash(figured_p(pitches))
        @test sort(collect(fp)) == map(midi, [3, 5, 11])
        @test length(fp) == 3
        @test transpose_by(fp, midi(1)) == figured_p(map(inc, pitches))
        @test bass(transpose_to(fp, midi(3))) == midi(3)
        @test figures(transpose_to(fp, midi(3))) == figures(fp)
        @test pc(fp) == figured_pc(pitches)
    end

    @testset "FiguredPitch" begin
        fp = figured_pc(pitches)
        @test bass(fp) == midi(11)
        @test sort(collect(figures(fp))) == map(midi, [0, 4, 6])
        @test fp == figured_pc(pitches)
        @test fp == figured_pc(shuffle(pitches))
        @test hash(fp) == hash(figured_pc(pitches))
        @test sort(collect(fp)) == map(midi, [3, 5, 11])
        @test length(fp) == 3
        @test transpose_by(fp, midi(1)) == figured_pc(map(inc, pitches))
        @test bass(transpose_to(fp, midi(15))) == midi(3)
        @test figures(transpose_to(fp, midi(3))) == figures(fp)
        @test pc(fp) == fp
    end
end
