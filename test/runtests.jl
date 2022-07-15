using MPITestImages
using Test
using Documenter

DocMeta.setdocmeta!(MPITestImages, :DocTestSetup, :(using MPITestImages); recursive=true)

@testset "MPITestImages.jl" begin
  @testset "Doctest" begin
    doctest(MPITestImages; manual = false)
  end
end
