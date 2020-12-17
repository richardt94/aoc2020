function parseword(s::String)
    passgroups = match(r"^([0-9]+)-([0-9]+) ([a-z]): ([a-z]+)", s)
    minmatches = parse(Int, passgroups[1])
    maxmatches = parse(Int, passgroups[2])
    letter = passgroups[3][1]
    password = passgroups[4]

    lcount = 0
    for i = 1:length(password)
        if password[i]==letter
            lcount += 1
        end
    end

    if lcount < minmatches || lcount > maxmatches
        return false
    end
    return true
end

function parseword2(s::String)
    passgroups = match(r"^([0-9]+)-([0-9]+) ([a-z]): ([a-z]+)", s)
    pos1 = parse(Int, passgroups[1])
    pos2 = parse(Int, passgroups[2])
    letter = passgroups[3][1]
    password = passgroups[4]

    return (password[pos1] == letter) ⊻ (password[pos2] == letter)
end