module Lyceum

using Reexport
using Pkg

@reexport using LyceumBase
@reexport using LyceumMuJoCo
@reexport using LyceumAI
@reexport using MuJoCo
@reexport using Shapes

export LyceumBase, LyceumMuJoCo, LyceumAI, MuJoCo, Shapes

const LYCEUM_PACKAGES = [
    "LyceumBase",
    "LyceumMuJoCo",
    "LyceumAI",
    "MuJoCo",
    "Shapes",
]

# packages which are in the tomls but not aren't loaded (i.e. with using) by default
const UNUSED_LYCEUM_PACKAGES = [
    "LyceumMuJoCoViz" # so that `using Lyceum` works on headless machines
]

function pkgspecs(;ignore_versions::Bool = false, rev::Union{AbstractString, Nothing} = nothing)
    if !ignore_versions && rev !== nothing
        throw(ArgumentError("Cannot ignore versions and specify a revision at the same time"))
    end
    toml = Pkg.TOML.parsefile(joinpath(@__DIR__, "../Project.toml"))
    specs = Pkg.Types.PackageSpec[]
    for (name, uuid) in toml["deps"]
        if rev !== nothing
            spec = PackageSpec(name = name, uuid = uuid, rev = rev)
        elseif !ignore_versions && haskey(toml["compat"], name)
            v = toml["compat"][name]
            spec = PackageSpec(name = name, uuid = uuid, version = v)
        else
            spec = PackageSpec(name = name, uuid = uuid)
        end
        push!(specs, spec)
    end
    specs
end

function devall()
    lyceumpkgs = [LYCEUM_PACKAGES..., UNUSED_LYCEUM_PACKAGES...]
    specs = filter(s -> s.name in lyceumpkgs, pkgspecs(ignore_versions = true))
    Pkg.develop(specs)
end

function addall(;ignore_versions::Bool = false, rev::Union{AbstractString, Nothing} = nothing)
    lyceumpkgs = [LYCEUM_PACKAGES..., UNUSED_LYCEUM_PACKAGES...]
    specs = filter(s -> s.name in lyceumpkgs, pkgspecs(ignore_versions = ignore_versions, rev = rev))
    Pkg.add(specs)
end

end # module
