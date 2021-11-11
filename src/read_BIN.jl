function read_BIN(file, unpack = false)
    io = open(file, "r")

    endian = read(io, UInt16) |> Int64

    if endian != 18754
        @error "NOT Implemented Big-endian file read"
    end

    version = read(io, 6) |> String
    version = "BI" * version
    ver = VersionNumber(strip(version[5:8]))

    type = read(io, 8) |> String
    descr = read(io, 80) |> String

    # read indices
    # integers:inint,indbls,inval1,inval2,ipval1,ipval2
    metaint = Array{UInt32}(undef, 4)
    read!(io, metaint)
    # put index data in structure array
    nints = metaint[1]
    ndbls = metaint[2]
    nval1 = metaint[3]
    nval2 = metaint[4]

    # compatibility clause (pval are long integers in newer versions)
    if ver < v"2.4"
        metaint = Array{UInt32}(undef, 2)
        read!(io, metaint)
        pval1 = metaint[1]
        pval2 = metaint[2]
    else
        metaint = Array{UInt64}(undef, 2)
        read!(io, metaint)
        pval1 = metaint[1]
        pval2 = metaint[2]
    end

    # compatibility clause
    if ver <= v"2.1"
        if type in ["SYMV0___", "BDFULLV0", "BDSYMV0", "BDFULLVN"]
            nvec = 0
            pval2 = 1
        elseif type == "SYMV1___"
            nvec = 1
            pval2 = 1
        elseif type == "SYMV2___"
            nvec = 2
            pval2 = 1
        elseif type == "FULLSQV0"
            nvec = 0
            pval2 = pval1
        end

        nread = 0
        nval2 = nval1
    else
        nvec = read(io, Int32)
        nread = read(io, Int32)
    end

    # Type dependent index data
    nblocks = -1
    if type in ["BDSYMV0_", "BDFULLV0", "BDSYMVN_", "BDFULLVN"]
        nblocks = read(io, Int32)
    end

    # get meta data
    # readme array
    readme = ""
    if nread > 0
        list = read(io, nread * 80) |> String
        readme = list
    end

    # integers
    if nints > 0
        # compatibility clause
        if ver <= v"2.4"
            list = read(io, nints * 24) |> String
            ints_d = map(s -> *(s...) |> strip, eachcol(reshape(split(list, ""), 24, :)))
            ints = Array{Int32}(undef, nints)
            read!(io, ints)
        else
            list = read(io, nints * 24) |> String
            ints_d = map(s -> *(s...) |> strip, eachcol(reshape(split(list, ""), 24, :)))
            ints = Array{Int64}(undef, nints)
            read!(io, ints)
        end
    end

    # doubles
    if ndbls > 0
        list = read(io, ndbls * 24) |> String
        dbls_d = map(s -> *(s...) |> strip, eachcol(reshape(split(list, ""), 24, :)))
        dbls = Array{Float64}(undef, ndbls)
        read!(io, dbls)
    end

    # side description meta data
    list = read(io, nval1 * 24) |> String
    side1_d = map(s -> *(s...) |> strip, eachcol(reshape(split(list, ""), 24, :)))

    # type specific meta data
    if type in ["BDSYMV0_", "BDFULLV0", "BDSYMVN_", "BDFULLVN"]
        blockind = Array{Int32}(undef, nblocks)
        read!(io, blockind)
    end

    if type in ["BDFULLV0", "BDFULLVN", "FULLSQV0", "FULLSQVN"]

        # compatibility clause
        if ver <= v"2.2"
            side2_d = side1_d
        else
            list = read(io, nval2 * 24) |> String
            side2_d = map(s -> *(s...) |> strip, eachcol(reshape(split(list, ""), 24, :)))
        end

    elseif type == "FULL2DVN"
        list = read(io, nval2 * 24) |> String
        side2_d = map(s -> *(s...) |> strip, eachcol(reshape(split(list, ""), 24, :)))
    end

    # data (type dependent)

    # vectors
    vec = Float64[]
    if nvec > 0
        vec = Array{Float64}(undef, nval1, nvec)
        tmp = Array{Float64}(undef, nval1)

        for i = 1:nvec
            read!(io, tmp)
            vec[:, i] = tmp[:]
        end
    end

    # read matrix data
    pack1 = Array{Float64}(undef, pval1 * pval2)
    read!(io, pack1)

    close(io)

    mat1 = nothing
    if unpack == true
        # unpack if requested
        if type in ["SYMV0___", "SYMV1___", "SYMV2___", "SYMVN___"]

            # copy data from packed vector to full array
            mat1 = unpack(pack1)

        elseif type in ["BDSYMV0_", "BDSYMVN_"]
            # fill first block
            sz = blockind[1] |> Int
            shift1 = 1
            shift2 = sz * (sz + 1) / 2
            mat1_tmp = [unpack(pack1[shift1:shift2])]
            shift1 = shift2

            for i = 2:nblocks
                sz = blockind[i] - blockind[i-1] |> Int
                shift2 = shift1 + sz * (sz + 1) / 2
                push!(mat1_tmp, unpack(pack1[shift1+1:shift2]))
                shift1 = shift2
            end

            mat1 = BlockDiagonal(mat1_tmp)

        elseif type in ["BDFULLV0", "BDFULLVN"]
            # fill first block
            sz = blockind[1] |> Int
            shift1 = 1
            shift2 = sz^2
            mat1_tmp = [reshape(pack1[shift1:shift2], sz, sz)]
            shift1 = shift2

            for i = 2:nblocks
                sz = blockind[i] - blockind[i-1] |> Int
                shift2 = shift1 + sz^2
                push!(mat1_tmp, reshape(pack1[shift1+1:shift2], sz, sz))
                shift1 = shift2
            end

            mat1 = BlockDiagonal(mat1_tmp)

        elseif type in ["FULLSQV0", "FULLSQVN", "FULL2DVN"]
            mat1 = reshape(pack1, nval1, nval2)
        end
    end

    return DDK(
        version,
        ver,
        type,
        descr,
        readme,
        ints_d,
        ints,
        dbls_d,
        dbls,
        side1_d,
        side2_d,
        nblocks,
        blockind,
        vec,
        pack1,
        mat1,
    )

end

function unpack(pack)
    n = length(pack)
    nval = (-1 + sqrt(1 + 8 * n)) / 2 |> Int
    mat = zeros(Float64, nval, nval)

    st = 0
    for i = 1:nval
        mat[1:i, i] = pack[st+1:st+i]
        st += i
    end

    return mat
end