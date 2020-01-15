using Test, Pkg, Lyceum

function test_package(pkg::String)
    try
        Pkg.test(pkg)
        return true
    catch
        return false
    end
end

@testset "Lyceum.jl" begin
    @testset "$pkg" for pkg in [Lyceum.LYCEUM_PACKAGES..., Lyceum.UNUSED_LYCEUM_PACKAGES...]
        @test test_package(pkg)
    end
end
