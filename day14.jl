mutable struct BitmaskComputer
	mem::Dict{Int,Int}
	mask::String
end

BitmaskComputer() = BitmaskComputer(Dict{Int,Int}(), "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")

function execute(codefile::String)
	prog = split.(readlines(codefile))

	bc = BitmaskComputer()
	for line = prog
		if line[1] == "mask"
			bc.mask = line[3]
			# println("Mask is now ", bc.mask)
		else
			maddr = parse(Int,line[1][5:end-1])
			mval = parse(Int,line[3])
			addrs = decode(bc.mask, maddr)
			for a = addrs
				bc.mem[a] = mval
				# println("Writing ", mval, " to ", a)
			end
		end
	end

	println(sum([bc.mem[k] for k in keys(bc.mem)]))
end


function decode(mask::String, acode::Int)
	if length(mask) == 0
		return [0]
	end
	addrs = decode(mask[1:end-1], acode÷2)
	if mask[end] == 'X' #broadcast
		addrs = vcat(addrs .* 2 .+ 0, addrs .* 2 .+ 1)
	elseif mask[end] == '0' #unchanged
		addrs = addrs .* 2 .+ acode % 2
	elseif mask[end] == '1' #set bit
		addrs = addrs .* 2 .+ 1
	end
	return addrs
end