struct Rule
    subrules::Array{Array{Int,1},1}
    rule::Char
end

Rule() = Rule(Array{Array{Int,1},1}(), 'a')
Rule(c::Char) = Rule(Array{Array{Int,1},1}(), c)
Rule(subrules::Array{Array{Int,1},1}) = Rule(subrules, 'a')

function buildGraph(rules::Array{T,1} where T<:AbstractString)
    graph = [Rule() for _ in 1:length(rules)]
    internalrgx = r"^([0-9]+): ([0-9 |]+)$"
    leafrgx = r"^([0-9]+): \"([a-z])\"$"
    for rule = rules
        if occursin(internalrgx, rule)
            m = match(internalrgx, rule)
            ridx = parse(Int, m[1])
            subrulespec = [parse.(Int, x) for x in split.(split(m[2], "|"))]
            graph[ridx + 1] = Rule([subrule .+ 1 for subrule in subrulespec])
        else
            m = match(leafrgx, rule)
        	ridx = parse(Int,m[1])
            graph[ridx + 1] = Rule(m[2][1])
        end
    end

    graph
end

function matchrule(message::AbstractString, rulegraph::Array{Rule,1}, root::Int)
    if length(message) == 0; return false, "" end
    matched = false
    if length(rulegraph[root].subrules) == 0
        if message[1] == rulegraph[root].rule
            return true, message[2:end]
        else
            return false, ""
        end
	else
        for subrule in rulegraph[root].subrules
            matched = true
            remainder = message
            for component in subrule
                (matched, remainder) = matchrule(remainder, rulegraph, component)
                if !matched; break end
            end
            if matched; return true, remainder end
        end
	end

	return false, ""

end

function validate(f::String)
    rulemsg = split(read(f, String), "\n\n")
    rules = split(rulemsg[1],"\n")
    messages = split(rulemsg[2])

    rg = buildGraph(rules)

    function globalmatch(x)
        (matched, remainder) = matchrule(x, rg, 1)
        matched && (remainder == "")
    end

    sum(globalmatch.(messages))
end