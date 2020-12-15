function sumto2020(f::String)
    flns = readlines(f)
    counted = zeros(Int,2021)
    for line = flns
        intline = parse(Int, line)
        if intline <= 2020
            if counted[2020 - intline + 1] > 0
                return intline*(2020-intline)
            else
                counted[intline + 1] = 1
            end
        end
    end
    0
end

function sum3to2020(f::String)
    numbers = parse.(Int, readlines(f))
    counted = zeros(Int,2021)
    for n = numbers
        counted[n+1] = 1
    end

    for i1 = 1:length(numbers)
        for i2 = (i1+1):length(numbers)
            if numbers[i1] + numbers[i2] > 2020
                continue
            end
            if counted[2020 - numbers[i1] - numbers[i2] + 1] > 0
                return numbers[i1]*numbers[i2]*(2020-numbers[i1]-numbers[i2])
            end
        end
    end
    return 0
end

