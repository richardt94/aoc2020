function evaluate(expression::String)
	pvals = Array{Int,1}()
	cval = 0
	op = 1
	idx = 1
	while idx <= length(expression)
		ch = expression[idx]
		# println(ch)
		if ch == ' '; idx += 1; continue end
		if ch - '0' <= 9 && ch - '0' >= 0
			cval *= 10
			cval += ch - '0'
		elseif ch == '('
			(lbr, cval) = evaluate(expression[(idx+1):end])
			idx += lbr
			continue
		elseif ch == ')'
			push!(pvals, (op == 0) ? pop!(pvals) + cval : cval)
			return idx+1, prod(pvals)
		elseif ch == '+' || ch == '*'
			push!(pvals, (op == 0) ? pop!(pvals) + cval : cval)
			cval = 0
			op = (ch=='+') ? 0 : 1
		end
		# println("registers: ", pval, " ", cval)
		idx += 1
	end
	push!(pvals, (op == 0) ? pop!(pvals) + cval : cval)
	return idx, prod(pvals)

end

function evfile(f::String)
	exprs = readlines(f)
	res = [evaluate(expression)[2] for expression in exprs]

	println(res)
	sum(res)
end