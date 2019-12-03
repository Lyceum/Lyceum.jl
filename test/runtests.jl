using Test, Pkg, Lyceum

function test_package(name::String)
    try
        Pkg.test(name)
        return true
    catch
        return false
    end
end

@testset "Lyceum.jl" begin

    names = map(m->String(nameof(m)), Lyceum.LYCEUM_PACKAGES)
    @info names

    @testset "$name" for name in names
        @info name
        @test test_package(name)
    end
end
