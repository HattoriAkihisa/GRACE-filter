function filterSH(W::DDK, cnm, snm)
    
    # check if we have a block diagonal filter matrix

    if W.type == "BDFULLV0"
        # maximum degree of the input coefficients
        nmax = size(cnm, 1) - 1

        # Extract the minimum and maximum degree supported by the filter matrix
        nmaxfilt = W.ints[findfirst(str -> occursin("Lmax", str), W.ints_d)]
        nminfilt = W.ints[findfirst(str -> occursin("Lmin", str), W.ints_d)]

        # Determine the output maximum degree (limited by either the filter or input data)
        nmaxout = min(nmax, nmaxfilt)

        cnmfilt = zeros(nmax+1, nmax+1)
        snmfilt = zeros(nmax+1, nmax+1)

        lastblckind = 0
        lastindex = 0

        for iblk in 1:W.nblocks
            order = iblk ÷ 2

            order > nmaxout && break

            trig = mod(iblk + (iblk > 1), 2)

            sz = W.blockind[iblk] - lastblckind |> Int

            blockn = diagm(ones(nmaxfilt+1-order))
            nminblk = max(nminfilt, order)

            shft = nminblk - order + 1

            blockn[shft:end, shft:end] = reshape(W.pack1[lastindex+1:lastindex+sz^2], sz, sz)

            if trig == 1
                cnmfilt[order+1:nmaxout+1, order+1] = blockn[1:nmaxout+1-order, 1:nmaxout+1-order] * cnm[order+1:nmaxout+1, order+1]
            else
                snmfilt[order+1:nmaxout+1, order+1] = blockn[1:nmaxout+1-order, 1:nmaxout+1-order] * snm[order+1:nmaxout+1, order+1]
            end

            lastblckind = W.blockind[iblk]
            lastindex += sz^2
        end

    else
        @error "Not a block diagonal matrix"
    end

    return cnmfilt, snmfilt
end