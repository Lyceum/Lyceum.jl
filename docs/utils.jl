isliterate(file) = (@assert isfile(file); endswith(file, ".jl"))
ismarkdown(file) = (@assert isfile(file); endswith(file, ".md"))

# For process_literate and process_markdown, full path to srcfile is joinpath(root, rel_srcfile)
function process_literate(root, rel_srcfile, markdowndir, scriptdir, notebookdir)
    abs_srcfile = joinpath(root, rel_srcfile)
    rel_srcdir = dirname(rel_srcfile)

    @assert isdir(root)
    @assert isliterate(abs_srcfile)

    markdown_dstdir = joinpath(markdowndir, rel_srcdir)
    mkpath(markdown_dstdir)
    # Copy over source file and use that file instead for correct EditURL
    abs_srcfile = cp(abs_srcfile, joinpath(markdown_dstdir, basename(abs_srcfile)))
    @error abs_srcfile relpath(abs_srcfile, markdown_dstdir)
    Literate.markdown(abs_srcfile, markdown_dstdir; documenter = true)

    script_dstdir = joinpath(scriptdir, rel_srcdir)
    mkpath(script_dstdir)
    Literate.script(abs_srcfile, script_dstdir)

    notebook_dstdir = joinpath(notebookdir, rel_srcdir)
    mkpath(notebook_dstdir)
    Literate.notebook(abs_srcfile, notebook_dstdir)
end

function process_markdown(root, rel_srcfile, markdowndir)
    abs_srcfile = joinpath(root, rel_srcfile)
    abs_dstfile = joinpath(markdowndir, rel_srcfile)
    mkpath(dirname(abs_dstfile))
    @info "Copying Markdown file $abs_srcfile to $abs_dstfile"
    cp(abs_srcfile, abs_dstfile)
end

# Full path is joinpath(root, dir)
function process_dir(root, dir, markdowndir, scriptdir, notebookdir)
    seen = Set{Int}()
    abs_dir = normpath(joinpath(root, dir))
    for file_or_dir in readdir(abs_dir)
        abs_path = normpath(joinpath(abs_dir, file_or_dir))
        idtitle = parse_filename(abs_path)
        if isnothing(idtitle)
            @warn "Skipping $abs_path: does not match $NAME_REGEX"
            continue
        else
            id, title = idtitle
            if id in seen
                @warn "Skipping $abs_path duplicate page or section id: $id"
                continue
            else
                push!(seen, id)
                rel_path = normpath(joinpath(dir, file_or_dir))
                if isdir(abs_path)
                    process_dir(root, rel_path, markdowndir, scriptdir, notebookdir)
                elseif isliterate(abs_path)
                    process_literate(root, rel_path, markdowndir, scriptdir, notebookdir)
                elseif ismarkdown(abs_path)
                    process_markdown(root, rel_path, markdowndir)
                else
                    @warn "Skipping $abs_path: file does not end with .md or .jl"
                end
            end
        end
    end
end

function parse_filename(filename)
    m = match(NAME_REGEX, basename(filename))
    if isnothing(m)
        return nothing
    else
        id = parse(Int, m[1])
        title = replace(splitext(m[2])[1], '_'=>' ')
        return id, title
    end
end

function build_pages(root, dir)
    pages = Vector{Tuple{Int, String, Union{String, Vector}}}() # (id, title, page_or_section)
    abs_dir = normpath(joinpath(root, dir))
    for file_or_dir in readdir(abs_dir)
        abs_path = normpath(joinpath(abs_dir, file_or_dir))
        idtitle = parse_filename(file_or_dir)
        if isnothing(idtitle)
            @info "Skipping index entry $idtitle: does not match $NAME_REGEX"
            continue
        else
            id, title = idtitle
        end

        if isfile(abs_path)
            if ismarkdown(abs_path)
                # Only add markdown files to index
                page_or_section = relpath(abs_path, root)
            else
                continue
            end
        elseif isdir(abs_path)
            page_or_section = build_pages(root, joinpath(dir, file_or_dir))
        else
            error("$abs_path does not exist")
        end
        push!(pages, (id, title, page_or_section))
    end
    sort!(pages, by=first)
    pages = map(pages) do (_, title, page_or_section)
        title => page_or_section
    end
    return pages
end

function indented_println(xs...; indent = 0)
    for _ = 1:(Base.indent_width*indent)
        print(' ')
    end
    println(xs...)
end

function print_pages(index, indent=0)
    for (title, page_or_section) in index
        if page_or_section isa String
            indented_println(title, " => ", page_or_section, indent=indent)
        else
            indented_println(title, indent=indent)
            print_pages(page_or_section, indent + 1)
        end
    end
end

function headerprintln(x::AbstractString)
    if length(x) > 78
        println(x)
    else
        d, r = divrem(78 - length(x), 2)
        println(repeat('-', d), " ", x, " ", repeat('-', d+r))
    end
end

function lowercaseify!(srcdir)
    @assert isdir(srcdir)
    mktempdir() do tmpdir
        for (root, _, files) in walkdir(srcdir), file in files
            abs_srcpath = joinpath(root, file)
            rel_path = relpath(abs_srcpath, srcdir)
            abs_outpath = joinpath(tmpdir, lowercase(rel_path))
            mkpath(dirname(abs_outpath))
            cp(abs_srcpath, abs_outpath)
        end
        rm(srcdir, force=true, recursive=true)
        cp(tmpdir, srcdir)
    end
end


function create_example_project(dst_example_dir)
    # copy project skeleton over and setup project/manifest
    DevTools.cpinto(EXAMPLE_DIR, dst_example_dir)
    example_project = Dict{String, Any}()
    example_manifest = Dict{String, Any}()
    example_project["name"] = basename(dst_example_dir)
    example_project["uuid"] = EXAMPLE_UUID

    lyceum_project = Pkg.TOML.parsefile(joinpath(REPO_DIR, "Project.toml"))
    lyceum_manifest = Pkg.TOML.parsefile(joinpath(REPO_DIR, "Manifest.toml"))
    docs_project = Pkg.TOML.parsefile(joinpath(DOCS_DIR, "Project.toml"))
    docs_manifest = Pkg.TOML.parsefile(joinpath(DOCS_DIR, "Manifest.toml"))

    # sync with Lyceum
    example_project["version"] = lyceum_project["version"]
    example_project["deps"] = lyceum_project["deps"]
    example_project["compat"] = lyceum_project["compat"]

    # sync with example-specific deps from docs
    @assert !haskey(lyceum_project["deps"], "IJulia")
    @assert !haskey(lyceum_project["compat"], "IJulia")
    @assert !haskey(lyceum_project["deps"], "Plots")
    @assert !haskey(lyceum_project["compat"], "Plots")
    example_project["deps"]["IJulia"] = docs_project["deps"]["IJulia"]
    example_project["deps"]["Plots"] = docs_project["deps"]["Plots"]
    example_project["compat"]["IJulia"] = docs_project["compat"]["IJulia"]
    example_project["compat"]["Plots"] = docs_project["compat"]["Plots"]

    @assert length(docs_manifest["IJulia"]) == length(docs_manifest["Plots"]) == 1
    ijulia_ver = first(docs_manifest["IJulia"])["version"]
    plots_ver = first(docs_manifest["Plots"])["version"]

    # write project/manifest, overwriting if they exist
    open(joinpath(dst_example_dir, "Project.toml"), "w") do io
        Pkg.TOML.print(io, example_project)
    end
    open(joinpath(dst_example_dir, "Manifest.toml"), "w") do io
        Pkg.TOML.print(io, example_manifest)
    end

    # resolve Manifest
    oldproj = Base.active_project()
    olddir = pwd()
    try
        cd(dst_example_dir)
        Pkg.activate()
        Pkg.add([PackageSpec(name="IJulia", version=ijulia_ver), PackageSpec(name="Plots", version=plots_ver)])
        Pkg.instantiate()
    finally
        cd(olddir)
        Pkg.activate(oldproj)
    end
end


