mutable struct Console
	acc::Int
	ip::Int
end

Console() = Console(0,0)

function emulate(filename::String)
	instructions = split.(readlines(filename))
	console = Console()
	halt = false

	exec = zeros(Bool, length(instructions))
	while console.ip < length(instructions)
		if exec[console.ip + 1]
			return console.acc
		end
		print("executing instruction ",console.ip," ")
		exec[console.ip + 1] = true
		instr = instructions[console.ip + 1]
		i, arg = instr[1], parse(Int, instr[2])
		if i == "acc"
			println("acc")
			console.acc += arg
			console.ip += 1
		elseif i == "jmp"
			println("jmp")
			console.ip += arg
		elseif i == "nop"
			println("nop")
			console.ip += 1
		end
	end

	return console.acc

end