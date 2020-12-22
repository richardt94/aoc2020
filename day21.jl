function noallergens(file::String)
    foods = readlines(file)
    ingredients = Set{String}()
    allergens = Set{String}()

    counts = Dict{String,Int}()
    allergenic = Dict{String,Set{String}}()

    for food in foods
        m = match(r"([a-z ]+) \(contains ([a-z, ]+)\)", food)
        thisingredients = Set{String}(split(m[1]))
        thisallergens = Set{String}(split(m[2], ", "))
        for allergen = thisallergens
            if haskey(allergenic, allergen); allergenic[allergen] = intersect(allergenic[allergen], thisingredients)
            else; allergenic[allergen] = thisingredients end
        end
        allergens = union(allergens, thisallergens)
        ingredients = union(ingredients, thisingredients)
        for ingredient = thisingredients
            if haskey(counts, ingredient); counts[ingredient] += 1 else; counts[ingredient] = 1 end
        end
    end

    allallergenic = union(values(allergenic)...)
    notallergenic = setdiff(ingredients, allallergenic)
    sum([counts[ingredient] for ingredient = notallergenic])

    assigned = Set{String}()
    allergenmap = Array{Pair{String,String},1}()
    while length(allergens) > 0
        for allergen = allergens
            pingr = setdiff(allergenic[allergen], assigned)
            if length(pingr) == 1
                ingredient = pop!(pingr)
                push!(assigned, ingredient)
                push!(allergenmap, ingredient => allergen)
                delete!(allergens, allergen)
                break
            end
        end
    end

    sort!(allergenmap, lt = (a,b) -> isless(a[2], b[2]))
    join([a[1] for a in allergenmap], ",")
end