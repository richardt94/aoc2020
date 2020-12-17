function sum_code(lp::Int, numbers::Array{Int,1})
    #construct the set of possible sums
    sums = Dict{Int,Int}()

    for i = 1:lp
        for j = i+1:lp
            s = numbers[i]+numbers[j]
            if haskey(sums, s)
                sums[s] = sums[s] + 1
            else
                sums[s] = 1
            end
        end
    end

    for i = lp+1:length(numbers)
        newn = numbers[i]
        if !haskey(sums, newn)
            return newn
        end
        #remove the expired element from the set
        #and add the new one
        expired = numbers[i-lp]
        for j = (i-lp+1):(i-1)
            sums[expired + numbers[j]] -= 1
            if haskey(sums, newn + numbers[j])
                sums[newn+numbers[j]] += 1
            else
                sums[newn+numbers[j]] = 1
            end
            if sums[expired + numbers[j]] == 0
                delete!(sums, expired + numbers[j])
            end
        end

    end

    return 0

end

function sumtok(s::Int, numbers::Array{Int,1})
    cumsums = Dict{Int,Int}()
    cs = 0
    for (i,n) = enumerate(numbers)
        cs += n
        cumsums[cs] = i
    end

    for cusum = keys(cumsums)
        if haskey(cumsums, cusum-s) && (cumsums[cusum-s] <= cumsums[cusum] - 2)
            subseq = numbers[(cumsums[cusum-s]+1):cumsums[cusum]]
            return maximum(subseq) + minimum(subseq)
        end
    end
    return 0
end

function breakxmas(lp::Int, filename::String)
    numbers = parse.(Int, readlines(filename))
    s = sum_code(lp, numbers)
    sumtok(s, numbers)
end
