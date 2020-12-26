function playcupgame(arrangement::String, rounds::Int)
    cuplinks = zeros(Int,1000000)
    firstcups = [c - '0' for c = arrangement]
    cuplinks[firstcups[1:end-1]] = firstcups[2:end]
    cuplinks[firstcups[end]] = length(firstcups)+1
    cuplinks[(length(firstcups)+1):end-1] = (length(firstcups)+2):1000000
    cuplinks[end] = firstcups[1]

    curcup = firstcups[1]

    for i = 1:rounds
        pupset = (cuplinks[curcup], cuplinks[cuplinks[curcup]], cuplinks[cuplinks[cuplinks[curcup]]])
        dest = curcup - 1
        if dest < 1; dest = 1000000 end
        while(dest in pupset)
            dest -= 1
            if dest < 1; dest = 1000000 end
        end
        cuplinks[curcup] = cuplinks[pupset[3]]
        cuplinks[pupset[3]] = cuplinks[dest]
        cuplinks[dest] = pupset[1]
        curcup = cuplinks[curcup]
    end

    cuplinks[1] * cuplinks[cuplinks[1]]

end