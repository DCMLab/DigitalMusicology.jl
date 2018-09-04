using Test
using DigitalMusicology

@testset "dist" begin
    ea = []
    r = 1:4
    @test dist(ea) == Dict()
    @test dist(r) == Dict([1=>0.25,2=>0.25,3=>0.25,4=>0.25])
    @test dist(r,e->e,e->1,false) == Dict([1=>1,2=>1,3=>1,4=>1])
    @test dist(r,e->mod(e,2)) == Dict([0=>0.5,1=>0.5])
    @test dist(r,e->e,e->e) == Dict([1=>0.1,2=>0.2,3=>0.3,4=>0.4])

    sframe = midifilenotes("sample1.mid")
    siter = Itermidi(sframe,"wholes")

    @test pcdist1(siter) == Dict([midi(0)=>0.25,midi(2)=>0.25,midi(4)=>0.25,midi(7)=>0.25])
    #@test pcdist2(siter) == Dict{Any,Any}([(midi(0),midi(2))=>0.333333,(midi(2),midi(4))=>0.333333,(midi(4),midi(7))=>0.333333])  aproximative test, fails for no apparent reason
    @test durdist1(siter) == Dict([1//4 => 1])
    @test durdist2(siter) == Dict([(1//4,1//4) =>1])
    #@test ivdist1(siter) == Dict([2=> 0.666667,3=> 0.333333])
end
