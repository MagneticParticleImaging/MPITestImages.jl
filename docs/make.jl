using MPITestImages
using Documenter

DocMeta.setdocmeta!(MPISimulation, :DocTestSetup, :(using MPITestImages); recursive=true)

makedocs(;
    modules=[MPITestImages],
    authors="Jonas Schumacher <jonas.schumacher@imte.fraunhofer.de> and contributors",
    repo="https://github.com/MagneticParticleImaging/MPITestImages.jl/blob/{commit}{path}#{line}",
    sitename="FFLReco.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://github.com/MagneticParticleImaging/MPITestImages.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)
