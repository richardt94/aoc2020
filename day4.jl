function parseport(s::AbstractString)
	entries = split(s)
	pdict = Dict(map(x -> parsentry(x), entries))

	yearmatcher = r"^(\d{4})$"
	byr = 0
	iyr = 0
	eyr = 0

	try
		byr = parse(Int,match(yearmatcher,pdict["byr"])[1])
		iyr = parse(Int,match(yearmatcher,pdict["iyr"])[1])
		eyr = parse(Int,match(yearmatcher,pdict["eyr"])[1])
	catch
		return false
	end

	if (byr > 2002) | (byr < 1920) | (iyr < 2010) | (iyr > 2020) | (eyr < 2020) | (eyr > 2030)
		return false
	end

	hgtmatcher = r"^([0-9]+)(in|cm)$"
	hgt = 0
	unit = ""
	try
		m = match(hgtmatcher, pdict["hgt"])
		hgt = parse(Int,m[1])
		unit = m[2]
	catch
		return false
	end
	if (unit == "cm" && ((hgt < 150) | (hgt > 193))) | (unit == "in" && ((hgt < 59) | (hgt > 76)))
		return false
	end

	hclmatcher = r"^#([0-9a-f]{6})$"
	try
		if !occursin(hclmatcher, pdict["hcl"])
			return false
		end
	catch
		return false
	end

	eclmatcher = r"^(amb|blu|brn|gry|grn|hzl|oth)$"
	try
		if !occursin(eclmatcher, pdict["ecl"])
			return false
		end
	catch
		return false
	end

	pidmatcher = r"^\d{9}$"
	try
		if !occursin(pidmatcher, pdict["pid"])
			return false
		end
	catch
		return false
	end

	return true

end

function parsentry(s::AbstractString)
	m = r"^([a-z]+):(.+)$"
	rmatch = match(m, s)
	rmatch[1], rmatch[2]
end