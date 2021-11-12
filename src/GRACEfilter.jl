module GRACEfilter

export DDK
export read_BIN, readSH, filterSH

export DDK11, DDK10, DDK9
export DDK1, DDK2, DDK3, DDK4, DDK5, DDK6, DDK7, DDK8
export DDK0, DDKmin1, DDKmin2

using LinearAlgebra
using BlockDiagonals

struct DDK
    version
    ver

    type
    descr
    readme

    ints_d
    ints

    dbls_d
    dbls

    side1_d
    side2_d

    nblocks
    blockind

    vec
    pack1
    mat1

end

include("read_BIN.jl")
include("readSH.jl")
include("filterSH.jl")

DDK11 = joinpath(@__DIR__, "../data/DDKexperimental/Wbd_2-120.1e8p_4")
DDK10 = joinpath(@__DIR__, "../data/DDKexperimental/Wbd_2-120.2.5e8p_4")
DDK9  = joinpath(@__DIR__, "../data/DDKexperimental/Wbd_2-120.1e9p_4")
DDK8  = joinpath(@__DIR__, "../data/DDK/Wbd_2-120.a_5d9p_4")
DDK7  = joinpath(@__DIR__, "../data/DDK/Wbd_2-120.a_1d10p_4")
DDK6  = joinpath(@__DIR__, "../data/DDK/Wbd_2-120.a_5d10p_4")
DDK5  = joinpath(@__DIR__, "../data/DDK/Wbd_2-120.a_1d11p_4")
DDK4  = joinpath(@__DIR__, "../data/DDK/Wbd_2-120.a_5d11p_4")
DDK3  = joinpath(@__DIR__, "../data/DDK/Wbd_2-120.a_1d12p_4")
DDK2  = joinpath(@__DIR__, "../data/DDK/Wbd_2-120.a_1d13p_4")
DDK1  = joinpath(@__DIR__, "../data/DDK/Wbd_2-120.a_1d14p_4")
DDK0  = joinpath(@__DIR__, "../data/DDKexperimental/Wbd_2-120.5e14p_4")
DDKmin1 = joinpath(@__DIR__, "../data/DDKexperimental/Wbd_2-120.1e15p_4")
DDKmin2 = joinpath(@__DIR__, "../data/DDKexperimental/Wbd_2-120.5e15p_4")

end
