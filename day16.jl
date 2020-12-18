function fieldnames(fname::String, productfields::Array{String,1})
    lines = read(fname, String)
    sections = split(lines, "\n\n")
    fields = split(sections[1], "\n")
    yt = split(sections[2], "\n")[2]
    ot = split(sections[3], "\n")[2:end]

    #I know using dicts for this when the only way I ever access it
    #is looping over the keys is dumb but rewriting it isn't worth my time
    #if it works quickly enough
    ranges = Dict{String,Array{Pair{Int,Int},1}}()
    frgx = r"([a-z ]+): (\d+)-(\d+) or (\d+)-(\d+)"
    for field = fields
        m = match(frgx, field)
        r = parse.(Int, [m[2] m[3] m[4] m[5]])
        ranges[m[1]] = [r[1]=>r[2],r[3]=>r[4]]
    end

    otvals = map(x -> parse.(Int, split(x,",")), ot)

    vidx = valid(ranges, otvals)

    otvals = otvals[vidx]

    nf = length(keys(ranges))
    fieldmatrix = Dict{String,Array{Bool,1}}()
    for key in keys(ranges)
        fieldmatrix[key] = ones(Bool, nf)
    end

    for vals = otvals
        for (i, val) = enumerate(vals)
            for key = keys(ranges)
                ivfield = (val < ranges[key][1][1] || val > ranges[key][1][2]) &&
                            (val < ranges[key][2][1] || val > ranges[key][2][2])
                ivfield && (fieldmatrix[key][i] = false)
            end
        end
    end

    possibilities = [sum(fieldmatrix[key]) for key in keys(fieldmatrix)]

    sidx = sortperm(possibilities)

    sortedkeys = collect(keys(fieldmatrix))[sidx]
    sortedfmatrix = [fieldmatrix[key] for key in sortedkeys]

    for (i, row) = enumerate(sortedfmatrix)
        for j = (i+1):length(sortedfmatrix)
            sortedfmatrix[j] .⊻= sortedfmatrix[i]
        end
    end

    for (key, finalrow) = zip(sortedkeys, sortedfmatrix)
        fieldmatrix[key] = finalrow
    end

    println(fieldmatrix)

    ytvals = parse.(Int,split(yt,","))

    p = 1
    for field in productfields
        p *= ytvals[findall(fieldmatrix[field])[1]]
    end

    p
end

function valid(ranges::Dict{String, Array{Pair{Int,Int},1}}, ot::Array{Array{Int,1},1})
    vidx = ones(Bool, size(ot,1))
    for (i, vals) = enumerate(ot)
        for val in vals
            vfield = false
            for key in keys(ranges)
                vfield = (val >= ranges[key][1][1] && val <= ranges[key][1][2]) ||
                    (val >= ranges[key][2][1] && val <= ranges[key][2][2])
                vfield && break
            end
            vfield || (vidx[i] = false)
        end
    end
    vidx
end