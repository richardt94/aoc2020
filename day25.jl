function discretelog(a::Int, r::Int, m::Int)
    product = 1
    x = 0
    while product != a
        product *= r
        product %= m
        x += 1
    end
    x
end

function transform(x::Int, r::Int, m::Int)
    res = 1
    for i=1:x
        res *= r
        res %= m
    end
    res
end

function encryptionkey(file::String, r::Int, m::Int)
    pubkeys = parse.(Int, readlines(file))
    loopsizem = discretelog(pubkeys[2], r, m)
    transform(loopsizem, pubkeys[1], m)
end