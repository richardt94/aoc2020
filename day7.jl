#read a bag rule and return its
#colour and contents as String, Dict{String,Int}.
function readrule(s::String)
	rule = split(s, "contain")
	bcolrgx = r"^([a-z ]+) bag"
	colour = match(bcolrgx, rule[1])[1]

	if strip(rule[2]) == "no other bags."
		return colour, Dict{String,Int}()
	end

	contents = strip.(split(rule[2],","))
	crgx = r"^([0-9]+) ([a-z ]+) bag"
	m = match.(crgx, contents)
	cdict = Dict(map(x->String(x[2])=>parse(Int,x[1]), m))
	colour, cdict
end

function readruleset(filename::String)
	rulestrs = readlines(filename)
	rules = Dict(map(x-> String(x[1])=>x[2], readrule.(rulestrs)))
end

function outerbags(colour::String, graph::Dict{String,Dict{String,Int}})
	outers = Set{String}()
	for k in keys(graph)
		if haskey(graph[k], colour)
			push!(outers,k)
		end
	end

	indirect = Set{String}()
	for k in outers
		union!(indirect, outerbags(k, graph))
	end

	union!(outers, indirect)

	outers

end

function innerbags(colour::String, graph::Dict{String,Dict{String,Int}})
	inners = 0
	for k in keys(graph[colour])
		inners += graph[colour][k]
		inners += graph[colour][k]*innerbags(k, graph)
	end
	return inners
end