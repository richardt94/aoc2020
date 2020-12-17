function navigate(f::String)
    instructions = readlines(f)
    dir = 0
    dx = [1, 0, -1, 0]
    dy = [0, 1, 0, -1]

    x = 0
    y = 0

    for ins = instructions
        command = ins[1]
        arg = parse(Int,ins[2:end])
        if command == 'E'
            x += arg
        elseif command == 'N'
            y += arg
        elseif command == 'W'
            x -= arg
        elseif command == 'S'
            y -= arg
        elseif command == 'F'
            x += dx[dir+1]*arg
            y += dy[dir+1]*arg
        elseif command == 'L'
            dir = mod(dir + arg÷90, 4)
        elseif command == 'R'
            dir = mod(dir - arg÷90, 4)
        end
    end

    abs(x) + abs(y)
end

function waypointnavigate(f::String)
    instructions = readlines(f)
    dir = 0
    dx = [1, 0, -1, 0]
    dy = [0, 1, 0, -1]

    x = 0
    y = 0

    wx = 10
    wy = 1

    for ins = instructions
        command = ins[1]
        arg = parse(Int,ins[2:end])
        if command == 'E'
            wx += arg
        elseif command == 'N'
            wy += arg
        elseif command == 'W'
            wx -= arg
        elseif command == 'S'
            wy -= arg
        elseif command == 'F'
            x += wx*arg
            y += wy*arg
        elseif command == 'L'
            for _ = 1:arg÷90
                owy = wy
                wy = wx
                wx = -owy
            end
        elseif command == 'R'
            for _ = 1:arg÷90
                owy = wy
                wy = -wx
                wx = owy
            end
        end
    end

    abs(x) + abs(y)
end