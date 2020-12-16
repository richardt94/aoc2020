function simulatestep!(seats::Array{Int,2})
	nx = size(seats, 1)
	ny = size(seats, 2)

	seats2 = copy(seats)

	changed = false
	for i=1:nx
		for j=1:ny
			if seats2[i,j] == 1 || seats2[i,j] == 2
				nocc = 0
				if i > 1
					if seats2[i-1,j] == 2
						nocc += 1
					end
					if j > 1 && seats2[i-1,j-1] == 2
						nocc += 1
					end
					if j < ny && seats2[i-1,j+1] == 2
						nocc += 1
					end
				end
				if j > 1 && seats2[i,j-1] == 2
					nocc += 1
				end
				if j < ny && seats2[i,j+1] == 2
					nocc += 1
				end
				if i < nx
					if seats2[i+1,j] == 2
						nocc += 1
					end
					if j > 1 && seats2[i+1,j-1] == 2
						nocc += 1
					end
					if j < ny && seats2[i+1,j+1] == 2
						nocc += 1
					end
				end
			end

			if seats2[i,j] == 1 && nocc == 0
				seats[i,j] = 2
				changed = true
			elseif seats[i,j] == 2 && nocc >= 4
				seats[i,j] = 1
				changed = true
			end
		end
	end
	return changed
end

function readseats(f::String)
	schars = hcat(collect.(readlines(f))...)

	sym2num = x -> (x == '.') ? 0 : (x == 'L') ? 1 : 2

	seats = sym2num.(schars)

	return seats
end

function simulate(f::String)
	seats = readseats(f)
	changed = true
	while changed
		changed = simulatestep_LoS!(seats)
	end
	sum(seats .== 2)
end

function simulatestep_LoS!(seats::Array{Int,2})
	nx = size(seats, 1)
	ny = size(seats, 2)

	seats2 = copy(seats)

	changed = false
	for i=1:nx
		for j=1:ny
			if seats2[i,j] == 1 || seats2[i,j] == 2
				nocc = 0
				for dir=0:8
					if dir == 4
						continue
					end
					dx = dir÷3 - 1
					dy = dir%3 - 1
					i2 = i + dx
					j2 = j + dy
					while (i2 >= 1 && i2 <= nx && j2 >= 1 && j2 <= ny)
						if seats2[i2,j2] == 1
							break
						end
						if seats2[i2,j2] == 2
							nocc += 1
							break
						end
						i2 += dx
						j2 += dy
					end
				end
			end

			if seats2[i,j] == 1 && nocc == 0
				seats[i,j] = 2
				changed = true
			elseif seats[i,j] == 2 && nocc >= 5
				seats[i,j] = 1
				changed = true
			end
		end
	end
	return changed
end

