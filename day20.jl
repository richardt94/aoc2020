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



function buildimage(f::String)
    #edges are stored in [upper, right, lower, left] order.
    #vertical edges (left, right) are stored top-to-bottom
    #horizontal edges (upper, lower) are stored left-to-right
    rotate(edges) = [edges[4][end:-1:1], edges[1], edges[2][end:-1:1], edges[3]]
    flip(edges) = [edges[3], edges[2][end:-1:1], edges[1], edges[4][end:-1:1]]

    function fliprot(orientation, edges)
        if orientation ÷ 4 > 0
            edges = flip(edges)
        end
        for i=1:orientation%4
            edges = rotate(edges)
        end
        edges
    end
    (tileIDs, tiles) = readtiles(f)
    edgesets = [[tile[1,:], tile[:, end], tile[end,:], tile[:,1]] for tile in tiles]

    edgesdict = Dict{Int,Array{Array{Int,1},1}}()
    for (edges, tID) = zip(edgesets, tileIDs)
        edgesdict[tID] = edges
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
        edges = fliprot(orientation, edgesdict[tID])
        if y > 1
            above = tID_sol[x,y-1]
            if above >= 0
                edgeabove = fliprot(orient_sol[x,y-1], edgesdict[above])[3][:]
                if !all(edges[3][:] .== edgeabove)
                    return false
                end
            end
        end
        if y < ntile
            below = tID_sol[x,y+1]
            if below >= 0
                edgebelow = fliprot(orient_sol[x,y+1], edgesdict[below])[1][:]
                if !all(edges[3][:] .== edgebelow)
                    return false
                end
            end
        end
        if x > 1
            left = tID_sol[x-1,y]
            if left >= 0
                edgeleft = fliprot(orient_sol[x-1,y], edgesdict[left])[2][:]
                if !all(edges[4][:] .== edgeleft)
                    return false
                end
            end
        end
        if x < ntile
            right = tID_sol[x+1,y]
            if right >= 0
                edgeright = fliprot(orient_sol[x+1,y], edgesdict[right])[4][:]
                if !all(edges[2][:] .== edgeright)
                    return false
                end
            end
        end

        # println("tid ", tID, " fits at ", x," ", y, orientation >= 4 ? " flipped and" : "", " rotated ",orientation % 4, " times")
        #delete this tile from the set so it cannot be reused, then write
        #the ID and orientation to the solution array
        delete!(tidset, tID)
        tID_sol[x,y] = tID
        orient_sol[x,y] = orientation

        #if we've reached this point at the bottom-right tile then
        #the board is solved
        if (x, y) == (ntile, ntile)
            return true
        end

        #make sure all the in-place messing with the tile IDs in recursive calls
        #doesn't break our iteration over tile IDs

        nextloc = (0,0)
        #snake across the board
        if y % 2 == 1 && x < ntile
            nextloc = (x + 1, y)
        elseif y % 2 == 0 && x > 1
            nextloc = (x - 1, y)
        else
            nextloc = (x, y+1)
        end

        for nextID = tidset
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
                return tID_sol[1,1]*tID_sol[1,end]*tID_sol[end,1]*tID_sol[end,end]
            end
        end
    end

    return 0
end
