module Lyceum

using Reexport
using Pkg

@reexport using LyceumBase
@reexport using LyceumMuJoCo
@reexport using LyceumAI

@reexport using MuJoCo
@reexport using Shapes
@reexport using UniversalLogger

export LyceumBase,
    LyceumMuJoCo, LyceumAI, MuJoCo, Shapes, UniversalLogger

const LYCEUM_PACKAGES = [
    LyceumBase,
    LyceumMuJoCo,
    LyceumAI,
    MuJoCo,
    Shapes,
    UniversalLogger,
]

function pkgspecs(ignore_versions = false)
    toml = Pkg.TOML.parsefile(joinpath(@__DIR__, "../Project.toml"))
    specs = Pkg.Types.PackageSpec[]
    for (name, uuid) in toml["deps"]
        if !ignore_versions && haskey(toml["compat"], name)
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
    lyceumpkgs = map(p -> string(nameof(p)), LYCEUM_PACKAGES)
    specs = filter(s -> s.name in lyceumpkgs, pkgspecs(true))
    Pkg.develop(specs)
end

function addall(ignore_versions = false)
    lyceumpkgs = map(p -> string(nameof(p)), LYCEUM_PACKAGES)
    specs = filter(s -> s.name in lyceumpkgs, pkgspecs(ignore_versions))
    Pkg.develop(specs)
end

end # module
