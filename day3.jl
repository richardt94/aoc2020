text2trees(s::String) = map(x -> (x=='#'), collect(s))

function counttrees(slopex::Int, slopey::Int, trees::Array{Bool,2})
	istree= idx->trees[slopey*(idx-1)+1,((slopex*(idx-1))%size(trees,2))+1]
	sum(istree.(1:(size(trees,1)-1)÷slopey + 1))
end