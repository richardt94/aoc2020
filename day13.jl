function earliestbus(f::String)
	busarray = readlines(f)
	arrivetime = parse(Int, busarray[1])
	ids = busIDs(busarray[2])
	et = typemax(Int)
	eid = 0
	for id = ids
		waittime = (arrivetime%id > 0) * (id - arrivetime%id)
		if waittime < et
			et = waittime
			eid = id
		end
	end
	et*eid
end

function busIDs(buses::String)
	ids = Array{Int,1}()
	busstrings = split(buses,",")
	for b = busstrings
		if b != "x"
			append!(ids, parse(Int,b))
		end
	end
	ids
end

function bussequence(buses::String)
	busstrings = split(buses,",")
	atimes = Array{Array{Int,1},1}()
	for (t,idstr) = enumerate(busstrings)
		if idstr == "x"
			continue
		end
		id = parse(Int,idstr)
		append!(atimes, [[id, t - 1]])
	end

	current_base = atimes[1][1]
	current_idx = 2
	t=0

	while current_idx <= length(atimes)
		id = atimes[current_idx][1]
		offset = atimes[current_idx][2]
		while (t+offset)%id != 0
			t += current_base
		end
		current_base = lcm(current_base, id)
		current_idx += 1
	end

	t

end
