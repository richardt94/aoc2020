mutable struct Console
	acc::Int
	ip::Int
end

Console() = Console(0,0)

function emulate(filename::String)
	instructions = split.(readlines(filename))
	emulate(instructions)
end

function emulate(instructions::Array{Array{T,1},1} where T<:AbstractString)
	console = Console()
	halt = false

	exec = zeros(Bool, length(instructions))
	while console.ip < length(instructions)
		if exec[console.ip + 1]
			return false, console.acc
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

	return true, console.acc
end

function trychangejmp(filename::String)
	instructions = split.(readlines(filename))
	trychangejmp(instructions)
end

function trychangejmp(instructions::Array{Array{T,1},1} where T<:AbstractString)
	for i = 1:length(instructions)
		instr = instructions[i]
		if instr[1] == "jmp"
			instr[1] = "nop"
			halted, acc = emulate(instructions)
			if halted
				return i, acc
			end
			instr[1] = "jmp"
		elseif instr[1] == "nop"
			instr[1] = "jmp"
			halted, acc = emulate(instructions)
			if halted
				return i, acc
			end
			instr[1] = "nop"
		end
	end
	return i, 0
end
