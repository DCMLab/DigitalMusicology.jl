using DigitalMusicology
#using DigitalMusicology.Notes
#include("C:/Users/Toussain/Documents/DCML/DigitalMusicology.jl/src/DigitalMusicology.jl")
using Test
using Plots

lframe = midifilenotes("laksin.mid")
liter = Itermidi(lframe,"secs")
keysom(liter)


@testset "mobility" begin

    lframe = midifilenotes("laksin.mid")
    liter = Itermidi(lframe,"wholes")
    ea = []
    @test mobility(ea) == []
    #test with laksin.mid, length of arrays are equal
    #Julia  [0, 0.0, 0, 0.166667, 0.386322, 0.263754, 1.7454, 0.852011, 0.184192, 0.765752, 1.8761, 0.110236, 2.70097, 2.01592, 0.955004, 0.35166, 0.915004, 0.240131, 0.826335, 1.93549, 2.4542, 1.86349, 1.92259]
    #Matlab [0,0,0,0.1667,0.3863,0.2638,1.7454,0.8520,0.1842,0.7658,1.8761,0.1102,2.7010,2.0159,.9550,0.3517,0.9150,0.2401,0.8263,1.9355,2.4542,1.8635,1.9226]
end

@testset "melaccent" begin
    ea = []
    #@test melaccent(ea) == []
    lframe = midifilenotes("laksin.mid")
    liter = Itermidi(lframe,"wholes")
    # MatLab [1,1,1.0000e-05,0.5000,0.2500,0.2500,0.3550,0.0957,0.5561,0.0850,0.3550,0.0957,0.6700,1.0000e-05,0.5000,0.2500,0.3550,0.2407,0.0850,0.2500,0.3550,0.2900,0]
    # Julia  [1.00,1.00,0.0000100,0.500,0.250,0.250,0.355,0.0957,0.556…,0.0850,0.355,0.0957,0.670,0.0000100,0.500,0.250,0.355,0.241…,0.0850,0.250,0.355,0.290,0.00]

end
