@testset "modints" begin
    a = ModInt{7}(12)
    @test a == ModInt{7}(5)
    @test inv(a) * a == one(ModInt{7})
    @test a - a == zero(ModInt{7})
    @test ModInt{7}(4) < ModInt{7}(5)
    @test abs(a) == 2
    @test collect(0:5)[ModInt{10}(4)] == 4
    @test Int(ModInt{7}(3)) == 3
end