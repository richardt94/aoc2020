abstract type RuleNode end

mutable struct InternalRule <: RuleNode
	subrules::Array{Array{RuleNode,1},1}
end

struct LeafRule <: RuleNode
	rule::Char
end

