using MPITestImages
using Test
using Documenter
using Aqua

DocMeta.setdocmeta!(MPITestImages, :DocTestSetup, :(using MPITestImages); recursive=true)

@testset "MPITestImages.jl" begin
  @testset "Aqua" begin
    Aqua.test_all(MPITestImages, ambiguities=false)
  end

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

  @testset "TestImage struct" begin
    # generate am empty test image
    name = "This Image does not exist"

    @test_throws ErrorException("The given name `$name` did not match a known test image.") newTestImage = TestImage(name)

    # now generate a simple image that does exist
    name = "sine_bar_phantom"
    newTestImage = TestImage(name, (30, 30))

    @test MPITestImages.name(newTestImage) == name
    @test data(newTestImage)[1, 6] == 1.0 && isapprox(data(newTestImage)[end, end], 0.095, atol=0.001)
  end

end
