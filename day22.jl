function combatstep!(p1::Vector{Int}, p2::Vector{Int})
    c1 = popfirst!(p1)
    c2 = popfirst!(p2)
    c1 > c2 ? append!(p1, [c1, c2]) : append!(p2, [c2, c1])
end

function playcombat!(p1::Vector{Int}, p2::Vector{Int})
    while length(p1) > 0 && length(p2) > 0
        combatstep!(p1, p2)
    end
end

function readdeck(file::String)
    deckspec = read(file, String)
    p1spec = match(r"Player 1:\n([0-9\n]+)", deckspec)[1]
    p1 = parse.(Int, split(p1spec))
    p2spec = match(r"Player 2:\n([0-9\n]+)", deckspec)[1]
    p2 = parse.(Int, split(p2spec))
    ncards = length(p1)+length(p2)
    ncards, p1, p2
end

function playcombat(file::String)
    (ncards, p1, p2) = readdeck(file)
    playcombat!(p1,p2)
    sum([p1;p2].*(ncards:-1:1))
end

function recursivecombatgame!(p1::Vector{Int}, p2::Vector{Int})
    # mp1 = maximum(p1)
    # mp2 = maximum(p2)
    # ncards = length(p1) + length(p2)
    # if sub && mp1 > mp2 && mp1 > ncards
    #     return true
    # end
    visited = Set()
    while length(p1) > 0 && length(p2) > 0
        p1card = popfirst!(p1)
        p2card = popfirst!(p2)
        p1wins = false
        if (p1, p2) in visited
            return true
        elseif length(p1) >= p1card && length(p2) >= p2card
            p1wins = recursivecombatgame!(p1[1:p1card], p2[1:p2card])
        else
            p1wins = p1card > p2card
        end
        push!(visited, (copy(p1), copy(p2)))
        if p1wins
            push!(p1, p1card)
            push!(p1, p2card)
        else
            push!(p2, p2card)
            push!(p2, p1card)
        end
    end
    p1winsgame = (length(p1) > 0)
    return p1winsgame
end

function playrecursivecombat(file::String)
    (ncards, p1, p2) = readdeck(file)
    recursivecombatgame!(p1, p2)
    score([p1;p2])
end

score(deck::Vector{Int}) = sum(deck .* (length(deck):-1:1))