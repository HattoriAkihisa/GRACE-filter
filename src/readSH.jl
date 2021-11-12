function readSH(file; skip = 0)
    io = open(file, "r")
    
    for i in 1:skip
        readline(io)
    end

    lmax = -1
    str = ""
    while !eof(io)
        str = readline(io)
    end

    lmax = parse(Int, split(str)[1])

    ret = zeros(2, lmax+1, lmax+1)

    seekstart(io)
    for i in 1:skip
        readline(io)
    end

    while !eof(io)
        str = split(readline(io))
        
        degree = parse(Int, str[1])
        order  = parse(Int, str[2])
        cnm    = parse(Float64, str[3])
        snm    = parse(Float64, str[4])

        ret[1, degree+1, order+1] = cnm
        ret[2, degree+1, order+1] = snm
    end

    close(io)
    
    return ret
end