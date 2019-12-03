# Borrowed from the JuliaDocs org (https://raw.githubusercontent.com/JuliaDocs/juliadocs.github.io/source/make.jl)
# Types and functions to generate a Markdown table with links to package badges etc.
struct PackageDefinition
    name::String
    url::String
    docs::Vector{Pair{String,String}} # type => URL
    buildbadges::Vector{Pair{String,String}} # badge => URL
end

function markdown_nodocs(p::PackageDefinition)
    row = Any[]
    push!(row, Markdown.Link(p.name, p.url))
    push!(
        row,
        [Markdown.Link([Markdown.Image(image, "")], url) for (image, url) in p.buildbadges],
    )
end

function package_table_markdown_nodocs(packages)
    titles = map(["Package", "Build Status"]) do s
        Markdown.Bold(s)
    end
    table = Markdown.Table([titles], [:l, :c])
    for p in packages
        push!(table.rows, markdown_nodocs(p))
    end
    Markdown.MD(table)
end

const LYCEUM_PACKAGE_DEFS = [
    PackageDefinition(
        "Lyceum", "https://github.com/Lyceum/Lyceum.jl",
        [
            "stable" => "https://lyceum.github.io/Lyceum.jl/stable/",
            "dev" => "https://lyceum.github.io/Lyceum.jl/dev/",
        ],
        [
            "https://github.com/Lyceum/Lyceum.jl/workflows/CI/badge.svg" => "https://github.com/Lyceum/Lyceum.jl/actions",
        ]
    ),
    PackageDefinition(
        "LyceumBase", "https://github.com/Lyceum/LyceumBase.jl",
        [
            "stable" => "https://lyceum.github.io/LyceumBase.jl/stable/",
            "dev" => "https://lyceum.github.io/LyceumBase.jl/dev/",
        ],
        [
            "https://github.com/Lyceum/LyceumBase.jl/workflows/CI/badge.svg" => "https://github.com/Lyceum/LyceumBase.jl/actions",
        ]
    ),
    PackageDefinition(
        "LyceumAI", "https://github.com/Lyceum/LyceumAI.jl",
        [
            "stable" => "https://lyceum.github.io/LyceumAI.jl/stable/",
            "dev" => "https://lyceum.github.io/LyceumAI.jl/dev/",
        ],
        [
            "https://github.com/Lyceum/LyceumAI.jl/workflows/CI/badge.svg" => "https://github.com/Lyceum/LyceumAI.jl/actions",
        ]
    ),
    PackageDefinition(
        "LyceumMuJoCo", "https://github.com/Lyceum/LyceumMuJoCo.jl",
        [
            "stable" => "https://lyceum.github.io/LyceumMuJoCo.jl/stable/",
            "dev" => "https://lyceum.github.io/LyceumMuJoCo.jl/dev/",
        ],
        [
            "https://github.com/Lyceum/LyceumMuJoCo.jl/workflows/CI/badge.svg" => "https://github.com/Lyceum/LyceumMuJoCo.jl/actions",
        ]
    ),
    PackageDefinition(
        "LyceumViz", "https://github.com/Lyceum/LyceumViz.jl",
        [
            "stable" => "https://lyceum.github.io/LyceumViz.jl/stable/",
            "dev" => "https://lyceum.github.io/LyceumViz.jl/dev/",
        ],
        [
            "https://github.com/Lyceum/LyceumViz.jl/workflows/CI/badge.svg" => "https://github.com/Lyceum/LyceumViz.jl/actions",
        ]
    ),
    PackageDefinition(
        "Shapes", "https://github.com/Lyceum/Shapes.jl",
        [
            "stable" => "https://lyceum.github.io/Shapes.jl/stable/",
            "dev" => "https://lyceum.github.io/Shapes.jl/dev/",
        ],
        [
            "https://github.com/Lyceum/Shapes.jl/workflows/CI/badge.svg" => "https://github.com/Lyceum/Shapes.jl/actions",
        ]
    ),
    PackageDefinition(
        "UniversalLogger", "https://github.com/Lyceum/UniversalLogger.jl",
        [
            "stable" => "https://lyceum.github.io/UniversalLogger.jl/stable/",
            "dev" => "https://lyceum.github.io/UniversalLogger.jl/dev/",
        ],
        [
            "https://github.com/Lyceum/UniversalLogger.jl/workflows/CI/badge.svg" => "https://github.com/Lyceum/UniversalLogger.jl/actions",
        ]
    ),
    PackageDefinition(
        "MuJoCo", "https://github.com/Lyceum/MuJoCo.jl",
        [
            "stable" => "https://lyceum.github.io/MuJoCo.jl/stable/",
            "dev" => "https://lyceum.github.io/MuJoCo.jl/dev/",
        ],
        [
            "https://github.com/Lyceum/MuJoCo.jl/workflows/CI/badge.svg" => "https://github.com/Lyceum/MuJoCo.jl/actions",
        ]
    ),
]