using MPITestImages
using Test
using Documenter

DocMeta.setdocmeta!(MPITestImages, :DocTestSetup, :(using MPITestImages); recursive=true)

@testset "MPITestImages.jl" begin
  @testset "testimage_gen macro" begin
    MPITestImages.@testimage_gen function test_image_fun() return ones(4, 4) end
    testVal = testimage("test_image_fun")
    @test testVal == ones(4, 4)

    @test_throws ErrorException("The on-the-fly image `test_image_fun` has already been added.") MPITestImages.addOnTheFlyImage(:test_image_fun)
    
    @test_warn "The on-the-fly image `phantom_brain_30` is already linked with a remote file but the on-the-fly variant will be priorized." MPITestImages.addOnTheFlyImage(:phantom_brain_30)
  end

  @testset "Doctest" begin
    doctest(MPITestImages; manual = false)
  end

end
