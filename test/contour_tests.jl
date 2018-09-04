using DigitalMusicology
using Test

@testset "melcontour" begin

    oneframe = midifilenotes("onenote.mid")
    lframe = midifilenotes("laksin.mid")
    ea = []
    oiter = Itermidi(oneframe,"wholes")
    liter = Itermidi(lframe,"wholes")
    pit(e) = (pitch(e)).pitch
    @test melcontour(ea,1//4,pit) == []
    @test melcontour(oiter,1//4,pit) == [62,62,62,62]
    @test melcontour(oiter,1//8,pit) == [62,62,62,62,62,62,62]
    @test melcontour(liter,1//4,pit) == [64, 71, 71, 67,64,	66,	67,	66,	66,	64,	71,	71,	67,	67,	64,	64,	64,	64]
    #@test melcontour(liter,1//16 ) == [64,64,71, 71, 71, 71,71,	71,	69,	69,	67,	67,	66,	66,	64,	64,	64,	64,	66,	66,	66,	66,	67,	67,	67,	67,	66,	66,	66,	66,	66,	66,	66,	66,	64,	64,	67,	67,	71,	71,	71,	71,	71,	71,	69,	69,	67,	67,	66,	66,	67,	67,	66,	66,	64,	64,	63,	63,	64,	64,	64,	64,	64,	64,	64,	64,	64,	64,	64,	64]
    @test melcontour(liter,1//16,pit) == [64,	64,	64,	64,	71,	71,	71,	71,	71,	71,	69,	69,	67,	67,	66,	66,	64,	64,	64,	64,	66,	66,	66,	66,	67,	67,	67,	67,	66,	66,	66,	66,	66,	66,	66,	66,	64,	64,	67,	67,	71,	71,	71,	71,	71,	71,	69,	69,	67,	67,	66,	66,	67,	67,	66,	66,	64,	64,	63,	63,	64,	64,	64,	64,	64,	64,	64,	64,	64,	64,	64,	64]
end

@testset "acorr" begin
    eframe = midifilenotes("empty.mid")
    eiter = Itermidi(eframe,"wholes")
    oframe = midifilenotes("onenote.mid")
    oiter = Itermidi(oframe,"wholes")
    @test acorr(eiter,1//4,e->(pitch(e)).pitch) == []
    # Caution : NaN values can be return by the autocor function as in Matlab
    #comparing values from Julia and Matlab is hard as the rounding is not the same, arrays below show the difference
    # Matlab :[1.0, 0.3236, -0.156, -0.2006, -0.1442, -0.0878, -0.2835, -0.1884, 0.1474, 0.3814, 0.1487, -0.0137, -0.0293, -0.146, -0.137, -0.128, -0.0382, 0.0517]
    #Julia : [1.0, 0.32357, -0.156024, -0.200644, -0.14421, -0.0877758, -0.283538, -0.18844, 0.147432, 0.381371, 0.148701, -0.0136692, -0.0292912, -0.145968, -0.136985, -0.128002, -0.0381761, 0.0516501]
end
