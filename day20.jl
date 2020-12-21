function readtiles(f::String)
    fstring = read(f, String)
    tilestrings = split.(split(fstring,"\n\n"), "\n")
    char2bool(x) = (x=='#') ? true : false
    str2bool(s) = char2bool.(collect(s))

    tileID(s) = parse(Int, match(r"Tile ([0-9]+):", s)[1])

    tileIDs = [tileID(t[1]) for t in tilestrings]
    tiles = ([hcat(str2bool.(t[2:end])...) for t in tilestrings])

    tileIDs, tiles
end

flip(a2d::Array{Bool,2}) = a2d[end:-1:1, :]
rotate(a2d::Array{Bool,2}) = a2d'[:, end:-1:1]

function fliprot(o::Int, a2d::Array{Bool,2})
    if o >= 4; a2d = flip(a2d) end
    for i = 1:o%4; a2d = rotate(a2d) end
    a2d
end

function buildimage(f::String)
    #edges are stored in [upper, right, lower, left] order.
    #vertical edges (left, right) are stored top-to-bottom
    #horizontal edges (upper, lower) are stored left-to-right
    rotateedge(edges) = [edges[4][end:-1:1], edges[1], edges[2][end:-1:1], edges[3]]
    flipedge(edges) = [edges[3], edges[2][end:-1:1], edges[1], edges[4][end:-1:1]]

    function fliprotedge(orientation, edges)
        if orientation ÷ 4 > 0
            edges = flipedge(edges)
        end
        for i=1:orientation%4
            edges = rotateedge(edges)
        end
        edges
    end
    (tileIDs, tiles) = readtiles(f)
    edgesets = [[tile[:,1], tile[end, :], tile[:,end], tile[1,:]] for tile in tiles]

    tilesdict = Dict{Int, Array{Bool,2}}()
    edgesdict = Dict{Int,Array{Array{Int,1},1}}()
    for (edges, tID, tile) = zip(edgesets, tileIDs, tiles)
        edgesdict[tID] = edges
        tilesdict[tID] = transpose(tile)
    end

    tidset = Set{Int}(tileIDs)

    ntilesq = length(tileIDs)

    ntile = floor(Int,sqrt(ntilesq))

    #we will store the state of the board as 
    #two matrices of integers, the tile tIDs
    #and the orientation - orientation is indexed 
    #as (number of rotations) + (is flipped?) * 4.
    #could do this as one matrix with a hash that combines
    #tile ID and orientation but this is slightly easier.
    #-1 corresponds to an unset tile
    tID_sol = -1 * ones(Int, ntile, ntile)
    orient_sol = -1 * ones(Int, ntile, ntile)

    function solve(tID, orientation, x, y)
        #does this tile fit here? if not, stop early and return
        edges = fliprotedge(orientation, edgesdict[tID])
        if y > 1
            above = tID_sol[x,y-1]
            if above >= 0
                edgeabove = fliprotedge(orient_sol[x,y-1], edgesdict[above])[3][:]
                if !all(edges[1][:] .== edgeabove)
                    return false
                end
            end
        end
        if y < ntile
            below = tID_sol[x,y+1]
            if below >= 0
                edgebelow = fliprotedge(orient_sol[x,y+1], edgesdict[below])[1][:]
                if !all(edges[3][:] .== edgebelow)
                    return false
                end
            end
        end
        if x > 1
            left = tID_sol[x-1,y]
            if left >= 0
                edgeleft = fliprotedge(orient_sol[x-1,y], edgesdict[left])[2][:]
                if !all(edges[4][:] .== edgeleft)
                    return false
                end
            end
        end
        if x < ntile
            right = tID_sol[x+1,y]
            if right >= 0
                edgeright = fliprotedge(orient_sol[x+1,y], edgesdict[right])[4][:]
                if !all(edges[2][:] .== edgeright)
                    return false
                end
            end
        end

        #delete this tile from the set so it cannot be reused, then write
        #the ID and orientation to the solution array
        delete!(tidset, tID)
        tID_sol[x,y] = tID
        orient_sol[x,y] = orientation

        #if we're at the last tile in the snake then we're done
        if (ntile % 2 == 1 && (x, y) == (ntile, ntile)) || (ntile % 2 == 0 && (x,y) == (1, ntile))
            return true
        end

        nextloc = (0,0)
        #snake across the board
        if y % 2 == 1 && x < ntile
            nextloc = (x + 1, y)
        elseif y % 2 == 0 && x > 1
            nextloc = (x-1, y)
        else
            nextloc = (x, y+1)
        end

        #make sure all the in-place messing with the tile IDs in recursive calls
        #doesn't break our iteration over tile IDs
        for nextID = copy(tidset)
            for orientation = 0:7
                solved = solve(nextID, orientation, nextloc...)
                if solved; return true end
            end
        end

        #no solution found - reinsert the tile into the set and undo
        #the changes to the solution board
        push!(tidset, tID)
        tID_sol[x,y] = -1
        orient_sol[x,y] = -1

        return false
    end

    alltids = copy(tidset)
    for cornertile = alltids
        for orientation = 0:7
            solved = solve(cornertile, orientation, 1, 1)
            if solved
                tileset = [[fliprot(orient_sol[i,j], tilesdict[tID_sol[i,j]])[2:end-1,2:end-1] for i in 1:ntile] for j in 1:ntile]
                image = vcat([hcat(tilecol...) for tilecol in tileset]...)
                return image
            end
        end
    end

    nothing
end

function findmonster(image::Array{Bool,2})
    monstertext = ["                  # ",
                   "#    ##    ##    ###",
                   " #  #  #  #  #  #   "]
    str2bool(s) = [c == '#' for c = s]'
    monster = vcat(str2bool.(monstertext)...)
    println(monster)
    monstermask = zeros(Bool, size(image))

    for o = 0:7
        trialmonster = fliprot(o, monster)
        sy = size(trialmonster, 1)
        sx = size(trialmonster, 2)
        for y=1:(size(image,1) - sy + 1)
            for x = 1:(size(image,2) - sx + 1)
                if all((image[y:(y+sy-1), x:(x+sx-1)] .& trialmonster) .== trialmonster)
                    monstermask[y:(y+sy-1), x:(x+sx-1)] .|= trialmonster
                end
            end
        end
    end

    sum(image .⊻ monstermask)
end

function buildandfind(f::String)
    tID_sol = buildimage(f)

end

function dispimage(image::Array{Bool,2})
    chars = map(x->x ? '#' : '.', image)
    [println(String(chars[i,:])) for i in 1:size(chars,1)]
    nothing
end