@testset "slices" begin
    s1 = Slice(0, 10, [1,2,3])
    s2 = Slice(0, 10, [1,2,3])
    s3 = Slice(10, 4, [0,3])
    s4 = Slice(14, 8, [1])

    @testset "equality & hashing" begin
        @test s1 == s2
        @test s1 != s3
        @test hash(s1) == hash(s2)
    end

    @testset "slice accessors" begin
        @test onset(s1) == 0
        @test onset(s3) == 10

        @test duration(s1) == 10
        @test duration(s3) == 4

        @test offset(s1) == 10
        @test offset(s3) == 14

        @test content(s1) == [1,2,3]
        @test content(s3) == [0,3]

        on = setonset(s1, 3)
        @test onset(on) == 3
        @test duration(on) == 10
        @test offset(on) == 13

        dur = setduration(s3, 8)
        @test onset(dur) == 10
        @test duration(dur) == 8
        @test offset(dur) == 18

        off = setoffset(s3, 12)
        @test onset(off) == 10
        @test duration(off) == 2
        @test offset(off) == 12

        ps = setcontent(s1, [2,3,4])
        @test onset(ps) == onset(s1)
        @test duration(ps) == duration(s1)
        @test offset(ps) == offset(s1)
        @test content(ps) == [2,3,4]

        @test updateonset(x->2, s3) == setonset(s3, 2)
        @test updateduration(x->8, s3) == setduration(s3, 8)
        @test updateoffset(x->9, s3) == setoffset(s3, 9)
        @test updatecontent(x->[0], s3) == setcontent(s3, [0])
    end

    @testset "Slice cost functions" begin
        @test skipcost(s1, s4) == 4
        @test skipcost(s3, s4) == 0
        @test onsetcost(s1, s4) == 14
        @test onsetcost(s3, s4) == 4
    end

    @testset "Slice n-gram functions" begin
        @test unwrapslices([s1, s3, s4]) ==
            [[1, 2, 3], [0, 3], [1]]
        @test sg_totaldur([s1, s4]) == 22
        @test sg_sumdur([s1, s4]) == 18
    end
end
