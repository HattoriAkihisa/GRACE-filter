module GRACEfilter

export DDK
export read_BIN, readSH, filterSH

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

end
