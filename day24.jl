function move(x::Int, y::Int, dir::Int)
    if dir == 0 #e
        x += 2
    elseif dir == 1 #se
        y -= 1
        x += 1
    elseif dir == 2 #sw
        y -= 1
        x -= 1
    elseif dir == 3 #w
        x -= 2
    elseif dir == 4 #nw
        y += 1
        x -= 1
    else #ne
        y += 1
        x += 1
    end
    return (x, y)
end

function tilepos(directions::String)
    i = 1
    (x,y) = (0,0)
    while i <= length(directions)
        if directions[i] == 'e'
            (x,y) = move(x,y,0)
            i += 1
        elseif directions[i] == 'w'
            (x,y) = move(x,y,3)
            i += 1
        elseif directions[i] == 'n'
            if directions[i + 1] == 'e'
                (x,y) = move(x,y,5)
            else
                (x,y) = move(x,y,4)
            end
            i += 2
        else
            if directions[i + 1] == 'e'
                (x,y) = move(x,y,1)
            else
                (x,y) = move(x,y,2)
            end
            i += 2
        end
    end
    (x,y)
end

function nflipped(file::String)
    tiles = readlines(file)
    flipped = Set{NTuple{2,Int}}()
    for tile = tiles
        pos = tilepos(tile)
        if pos in flipped
            delete!(flipped,pos)
        else
            push!(flipped,pos)
        end
    end
    println(length(flipped))
    return flipped
end

function simulate!(black::Set{NTuple{2,Int}}, days::Int)
    adjacent(x,y) = [(x-1,y-1),(x-1,y+1),(x+1,y-1),(x+1,y+1),(x-2,y),(x+2,y)]
    nadjblack(x,y) = sum([hex in black for hex in adjacent(x,y)])

    for i=1:days
        stepblack = Set{NTuple{2,Int}}()
        stepwhite = Set{NTuple{2,Int}}()
        for bhex in black
            adj = adjacent(bhex[1], bhex[2])
            nb = sum([hex in black for hex in adj])
            if nb == 0 || nb > 2
                push!(stepwhite, bhex)
            end
            for whex = adj
                if whex in black; continue end
                if nadjblack(whex[1], whex[2]) == 2
                    push!(stepblack, whex)
                end
            end
        end
        black = setdiff(black, stepwhite)
        black = union(black, stepblack)
    end
    length(black)
end
