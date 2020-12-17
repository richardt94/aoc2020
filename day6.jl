function groupSum(filename::String)
    filestr = read(filename, String)
    groups = split(filestr, "\n\n")
    counts = map(countGroup, groups)
    sum(counts)
end

function countGroup(group::AbstractString)
    qns = ones(Bool, 26)
    people = split(group)
    for p = people
        qp = zeros(Bool,26)
        for c = p
            idx = c - 'a' + 1
            if (idx >= 1) & (idx <= 26)
                qp[idx] = true
            end
        end
        qns .&= qp
    end
    sum(qns)
end