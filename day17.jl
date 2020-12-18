function conwaystep(state::Set{Array{Int,1}}, d::Int)
    ndir = 3^d
    function nneighbours(x::Array{Int,1})
        nn = 0
        for dir = 0:(ndir - 1)
            dir == ndir÷2 && continue
            dx = zeros(Int,d)
            for i = 1:d
                dx[i] = (dir÷(3^(i-1)))%3 - 1
            end
            in(x .+ dx, state) && (nn += 1)
            nn == 4 && return nn
        end
        nn
    end

    toAdd = Set{Array{Int,1}}()
    toDel = Set{Array{Int,1}}()

    for x = state
        nna = nneighbours(x)
        if nna < 2 || nna > 3
            push!(toDel, x)
        end

        #deal with inactive neighbours
        for dir = 0:(ndir - 1)
            dir == ndir÷2 && continue
            dx = zeros(Int,d)
            for i = 1:d
                dx[i] = (dir÷(3^(i-1)))%3 - 1
            end
            neighbour = x .+ dx
            in(neighbour, state) && continue
            nneighbours(neighbour) == 3 && push!(toAdd, neighbour)
        end

    end

    setdiff(union(state, toAdd), toDel)

end


function simulate(infile::String, dimension::Int, steps::Int)
    initspec = readlines(infile)
    state = Set{Array{Int,1}}()
    for (y, line) = enumerate(initspec)
        for (x, c) = enumerate(line)
            c == '#' && push!(state, [x-1;y-1;zeros(Int,dimension-2)])
        end
    end

    for i=1:steps
        state = conwaystep(state, dimension)
    end

    length(state)
end
