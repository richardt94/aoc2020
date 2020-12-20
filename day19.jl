struct Rule
    subrules::Array{Array{Int,1},1}
    rule::Char
end

Rule() = Rule(Array{Array{Int,1},1}(), 'a')
Rule(c::Char) = Rule(Array{Array{Int,1},1}(), c)
Rule(subrules::Array{Array{Int,1},1}) = Rule(subrules, 'a')

function buildGraph(rules::Array{T,1} where T<:AbstractString)
    graph = Dict{Int,Rule}() #[Rule() for _ in 1:length(rules)]
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

#hard-code looped matching for rules 8 and 11 (9 and 12 in our one-based indexing)
#returns possible remainders of the string after a match is found. If no match is found
#then the set of possible remainders will be empty.
function matchrule(message::AbstractString, rulegraph::Dict{Int,Rule}, root::Int)
    newrems = Set{String}()
    if length(message) == 0; return newrems end
    if length(rulegraph[root].subrules) == 0
        if message[1] == rulegraph[root].rule
            return Set{String}([message[2:end]])
        else
            return Set{String}()
        end
	elseif root == 9
        #rule 8 expands to "at least one copy of rule 42"
        remainders = matchrule(message, rulegraph, 43)
        newrems = remainders
        while length(remainders) > 0
            nextrems = Set{String}()
            for remainder = remainders
                nextrems = union(nextrems, matchrule(remainder, rulegraph, 43))
            end
            newrems = union(newrems, nextrems)
            remainders = nextrems
        end
    elseif root == 12
        #"at least one copy of 42 followed by the same number of copies of 31"
        n42rems = Array{Set{String},1}()
        remainders = matchrule(message, rulegraph, 43)
        push!(n42rems, remainders)
        while length(remainders) > 0
            nextrems = Set{String}()
            for remainder = remainders
                nextrems = union(nextrems, matchrule(remainder, rulegraph, 43))
            end
            push!(n42rems, nextrems)
            remainders = nextrems
        end

        for (n42, rems31) = enumerate(n42rems)
            currems = rems31
            for n31 = 1:n42
                nextrems = Set{String}()
                for remainder = currems
                    nextrems = union(nextrems, matchrule(remainder, rulegraph, 32))
                end
                currems = nextrems
            end
            newrems = union(newrems, currems)
        end

    else
        for subrule in rulegraph[root].subrules
            matched = true
            remainders = Set{String}([message])
            for component in subrule
                nextrems = Set{String}()
                for remainder = remainders
                    nextrems = union(nextrems, matchrule(remainder, rulegraph, component))
                end
                remainders = nextrems
            end
            newrems = union(newrems, remainders)
        end
	end
	return newrems
end

function validate(f::String)
    rulemsg = split(read(f, String), "\n\n")
    rules = split(rulemsg[1],"\n")
    messages = split(rulemsg[2])

    rg = buildGraph(rules)

    function globalmatch(x)
        remainders = matchrule(x, rg, 1)
        "" in remainders
    end

    sum(globalmatch.(messages))
end