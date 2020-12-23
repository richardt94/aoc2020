function combatstep!(p1::Array{Int,1}, p2::Array{Int,1})
    c1 = popfirst!(p1)
    c2 = popfirst!(p2)
    c1 > c2 ? append!(p1, [c1, c2]) : append!(p2, [c2, c1])
end

function playcombat!(p1::Array{Int,1}, p2::Array{Int,1})
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

VSet = Set{Tuple}

function recursivecombatstep!(p1::Array{Int,1}, p2::Array{Int,1}, visited::VSet)
    # if root
    #     println("Player 1"); println(join(p1," "))
    #     println("Player 2"); println(join(p2," "))
    #     println()
    # end
    p1card = popfirst!(p1)
    p2card = popfirst!(p2)
    p1wins = false
    if Tuple([p1; 0; p2]) in visited
        p1wins = true
    elseif length(p1) >= p1card && length(p2) >= p2card
        p1wins = recursivecombatgame!(p1[1:p1card], p2[1:p2card], sub = true)
    else
        p1wins = p1card > p2card
    end
    push!(visited, Tuple([p1; 0; p2]))
    prize = p1wins ? [p1card, p2card] : [p2card, p1card]
    append!(p1wins ? p1 : p2, prize)
    return
end

function recursivecombatgame!(p1::Array{Int,1}, p2::Array{Int,1}; sub = false)
    if sub
        mp1 = maximum(p1)
        mp2 = maximum(p2)
        if max(mp1, mp2) > length(p1) + length(p2)
            return mp1 > mp2
        end
    end
    visited = VSet()
    while length(p1) > 0 && length(p2) > 0
        recursivecombatstep!(p1, p2, visited)
    end
    p1wins = (length(p1) > 0)
    return p1wins
end

function playrecursivecombat(file::String)
    (ncards, p1, p2) = readdeck(file)
    recursivecombatgame!(p1, p2)
    sum([p1;p2] .* (ncards:-1:1))
end
