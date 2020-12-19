mutable struct Rule
    subrules::Array{Int,1}
    rule::Char
end

Rule() = Rule([], 'a')

function buildGraph(rules::Array{String,1})
    graph = Array{RuleNode,1}()
    internalrgx = r"^([0-9]+): ([0-9]+) ([0-9]+) | ([0-9]+) ([0-9]+)$"
    leafrgx = r"^([0-9]+): \"[a-z]\"$"
    for rule = rules
        if occursin(internalrgx, rule)
            m = match(internalrgx, rule)
            subrulespec = parse.(Int, split(split(m[2], "|")))
        else
            m = match(leafrgx, rule)
        end
    end
end


function matchrule(message::String, root::RuleNode)

end