using MPITestImages
using Test
using Documenter
using Aqua

DocMeta.setdocmeta!(MPITestImages, :DocTestSetup, :(using MPITestImages); recursive=true)

@testset "MPITestImages.jl" begin
  @testset "Aqua" begin
    Aqua.test_all(MPITestImages, ambiguities=false)
  end

  @testset "Doctest" begin
    doctest(MPITestImages; manual = false)
  end
end
