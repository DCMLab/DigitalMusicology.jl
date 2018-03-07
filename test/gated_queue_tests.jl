using DigitalMusicology.GatedQueues

@testset "Gated Queues" begin
    q = gatedq(Int, String)
    @test isempty(q)

    q2 = enqueue(q, 1, "a")
    q2 = enqueue(q2, 3, "c")
    q2 = enqueue(q2, 2, "b")
    @test values(q2) == ["a", "b", "c"]
    @test !isempty(q2)

    q3 = enqueue(q2, 1, "hello")
    q3 = reenqueue(q3, 3, "d")
    @test values(q3) == ["a", "b", "d"]

    rel, q4 = release(q3, 3)
    @test rel == ["a", "b"]
    @test values(q4) == ["d"]

    q5 = gatedq(Int, String)
    q5 = enqueue(q5, 0, "x")
    q5 = enqueue(q5, 2, "y")
    q5 = enqueue(q5, 4, "z")
    q6 = merge(string, q2, q5)
    @test values(q6) == ["x", "a", "by", "c", "z"]
end
