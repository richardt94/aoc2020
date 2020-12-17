function jth(j::Int, f::String)
    starting = parse.(Int, split(readline(f), ","))

    lastspoke = zeros(Int,j)

    i = 1
    for n = starting
        lastspoke[n + 1] = i
        i += 1
    end

    prevnum = starting[end]
    while i <= j
        if lastspoke[prevnum + 1] != 0
            tmp = i - 1 - lastspoke[prevnum + 1]
        else
            tmp = 0
        end
        lastspoke[prevnum + 1] = i - 1
        prevnum = tmp
        i += 1
    end

    prevnum
end
