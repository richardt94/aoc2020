function seatid(s::String)
	binarystr = replace(s, 'F'=> '0')
	binarystr = replace(binarystr, 'B'=> '1')
	binarystr = replace(binarystr, 'L'=> '0')
	binarystr = replace(binarystr, 'R'=> '1')
	parse(Int, binarystr, base=2)
end

function fillplane(bpasses::Array{String,1})
	seats = ones(Bool,1024)
	sids = seatid.(bpasses)
	seats[sids.+ 1] .= false
	minseat = minimum(sids)
	maxseat = maximum(sids)
	findall(x->x, seats[minseat+1:maxseat+1]) .+ (minseat - 1)
end