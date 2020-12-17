function joltsum(filename::String)
    jolts = parse.(Int,readlines(filename))
    joltsum(jolts)
end

function joltsum(jolts::Array{Int,1})
    sj = sort(jolts)
    println(sj)
    prev = 0
    n1 = 0
    n3 = 1
    for j = sj
        if j - prev == 1
            n1 += 1
        elseif j - prev == 3
            n3 += 1
        end
        prev = j
    end

    n1*n3
end

function waysto(filename::String)
    jolts = parse.(Int,readlines(filename))
    waysto(jolts)
end

function waysto(jolts::Array{Int,1})
    sj = sort(jolts)
    wt = zeros(Int,length(jolts))
    for (i,jolt) = enumerate(sj)
        if jolt <= 3
            wt[i] = 1
        end
        j = i - 1
        while j > 0 && sj[j] >= jolt - 3
            wt[i] += wt[j]
            j -= 1
        end
    end
    wt[end]
end