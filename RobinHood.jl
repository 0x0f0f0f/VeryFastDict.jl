import Libdl
import DataStructures: SwissDict
const robinhood = Libdl.dlopen("./robin_hood.so")

const robinhood_init = Libdl.dlsym(robinhood, :dict_init)
const robinhood_destruct = Libdl.dlsym(robinhood, :dict_destruct)
const robinhood_clear = Libdl.dlsym(robinhood, :dict_clear)
const robinhood_setindex = Libdl.dlsym(robinhood, :dict_setindex)
const robinhood_getindex = Libdl.dlsym(robinhood, :dict_getindex)
const robinhood_delete = Libdl.dlsym(robinhood, :dict_delete)
const robinhood_size = Libdl.dlsym(robinhood, :dict_size)
const robinhood_rehash = Libdl.dlsym(robinhood, :dict_rehash)
const robinhood_reserve = Libdl.dlsym(robinhood, :dict_reserve)

const P = 3179 # arbitrary constant used in testing

mutable struct RobinHood
    d::Ptr{Cvoid}
    function RobinHood()
        m = new(ccall(robinhood_init, Ptr{Cvoid}, ()))
        f(m) = ccall(robinhood_destruct, Cvoid, (Ptr{Cvoid},), m.d)
        finalizer(f, m)
    end
end

function test_juliadict(n)
    m = Dict{Int, Int}()
    for i = 1:n
        m[P*i] = i
    end
    for i = 1:n-1
        delete!(m, P*i)
    end
    return m[P*n]
end

function test_juliadict_lookup(n)
    m = Dict{Int, Int}()
    for i = 1:n
        m[P*i] = i
    end
    @time for i = 1:n-1
        m[P*i]
    end
end

function test_robinhood(n)
    m = RobinHood()
    for i = 1:n
        ccall(robinhood_setindex, Cvoid, (Ptr{Cvoid}, UInt64, UInt64), m.d, i, P*i)
    end
    for i = 1:n-1
        ccall(robinhood_delete, Cvoid, (Ptr{Cvoid}, UInt64), m.d, P*i)
    end
    result = ccall(robinhood_getindex, UInt64, (Ptr{Cvoid}, UInt64), m.d, P*n)
    return result
end

function test_robinhood_lookup(n)
    m = RobinHood()
    for i = 1:n
        ccall(robinhood_setindex, Cvoid, (Ptr{Cvoid}, UInt64, UInt64), m.d, i, P*i)
    end
    @time for i = 1:n-1
        ccall(robinhood_getindex, UInt64, (Ptr{Cvoid}, UInt64), m.d, P*i)
    end    
end

function test_swissdict(n)
    m = SwissDict{Int, Int}()
    for i = 1:n
        m[P*i] = i
    end
    for i = 1:n-1
        delete!(m, P*i)
    end
    return m[P*n]
end

function test_swissdict_lookup(n)
    m = SwissDict{Int, Int}()
    for i = 1:n
        m[P*i] = i
    end
    @time for i = 1:n-1
        m[P*i]
    end
end

# JIT warmup
test_robinhood(100)
test_juliadict(100)
test_swissdict(100)
test_robinhood_lookup(100)
test_juliadict_lookup(100)
test_swissdict_lookup(100)

println("robinhood insertion & deletion")
@time test_robinhood(10^7)

println("juliadict insertion & deletion")
@time test_juliadict(10^7)

println("swissdict insertion & deletion")
@time test_swissdict(10^7)

println("robinhood lookup")
test_robinhood_lookup(10^7)

println("juliadict lookup")
test_juliadict_lookup(10^7)

println("swissdict lookup")
test_swissdict_lookup(10^7)

# Libdl.dlclose(robinhood)
