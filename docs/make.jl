using Lyceum, Pkg, Documenter, Literate, DevTools, Markdown

const REPO_DIR = joinpath(@__DIR__, "..")
const DOCS_DIR = @__DIR__

const SRC_DIR = joinpath(DOCS_DIR, "src")
const ASSETS_DIR = joinpath(DOCS_DIR, "assets")
const OUTPUT_DIR = joinpath(DOCS_DIR, "output")

const EXAMPLE_DIR = joinpath(@__DIR__, "assets/LyceumExamples")
const EXAMPLE_UUID = "208cb147-aad3-4bdb-b918-25b9ecee4332"

const NAME_REGEX = r"^([0-9]+)-(.+)"

include("utils.jl")
include("package_definition.jl")

function setup_output_dir(clean)
    if isdir(OUTPUT_DIR) && clean
        rm(OUTPUT_DIR, recursive=true, force=true)
        mkpath(OUTPUT_DIR)
    elseif isdir(OUTPUT_DIR)
        error("$OUTPUT_DIR exists but clean was false")
    end
    src = mkpath(joinpath(OUTPUT_DIR, "src"))
    static = mkpath(joinpath(src, "static"))
    (
        src = src,
        example = mkpath(joinpath(static, basename(EXAMPLE_DIR))),
        markdown = src,
        script = mkpath(joinpath(static, "script")),
        notebook = mkpath(joinpath(static, "notebook"))
    )
end


function main(clean=true;kwargs...)
    paths = setup_output_dir(clean)

    #create_example_project(paths.example)

    headerprintln("Pre-processing Files")
    process_dir(SRC_DIR, ".", paths.markdown, paths.script, paths.notebook)

    println()
    headerprintln("Generating Page Index")
    @info relpath(paths.markdown, paths.src)
    pages = build_pages(paths.src, relpath(paths.markdown, paths.src))

    # Rename index file to index.md
    title, index_filename = pages[1]
    index_filename isa String || error("First entry must be a page, got $index_filename")
    index_path = joinpath(paths.src, index_filename)
    Base.rename(index_path, joinpath(dirname(index_path), "index.md"))
    pages[1] = Pair(title, joinpath(dirname(relpath(index_path, paths.src)), "index.md"))
    print_pages(pages)

    headerprintln("Generating Docs")
    makedocs(;
        #modules = [Lyceum, Lyceum.LYCEUM_PACKAGES...],
        format=Documenter.HTML(
            prettyurls=get(ENV, "GITHUB_ACTIONS", nothing) == "true",
        ),
        pages = pages,
        sitename = "Lyceum",
        authors = "Colin Summers",

        # source/build are specified relative to root
        root = OUTPUT_DIR,
        strict = false,
        #repo = "https://github.com/tkf/Transducers.jl/blob/{commit}{path}#L{line}",
        kwargs...
    )

    println()
    headerprintln("Deploying")
    deploydocs(
        repo = "github.com/Lyceum/Lyceum.jl.git",
        push_preview=true,
        root = OUTPUT_DIR,
    )
end

main(true)