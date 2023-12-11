
@testset "Test all phantoms generated on the fly" begin
    @testset "delta image phantom" begin
        phantom = delta_image(
            (20, 20),
            3,
            sizeOfPoint = (3, 3),
            distanceOfPoints = (x -> 0, x -> 6),
            pivot = (3, 3),
        )

        @test phantom[4, 4] == 1.0
        @test phantom[4, 10] == 1.0
        @test phantom[4, 6:8] == [0.0, 0.0, 0.0]

        phantom = delta_image(
            (20, 20),
            3,
            sizeOfPoint = (3, 3),
            distanceOfPoints = (x -> 0, x -> 6),
            pivot = (3, 3),
            circularShape = true,
        )

        @test phantom[3, 3] == 0.0
        @test phantom[4, 4] == 1.0
    end

    @testset "checker image phantom" begin
        phantom = checker_image()

        @test phantom[2:3, 2:3] == ones(2, 2)
        @test phantom[5:6, 5:6] == ones(2, 2)
    end

    @testset "derenzo image and Jaszczak phantom" begin
        wrongPointSizes = [0, 0, 0, 0, 0]

        @test_throws ArgumentError(
            "Invalid length of vector $wrongPointSizes. Should atleast be 6!",
        ) derenzo_image(0, wrongPointSizes, 1)

        d = 150
        gap = 20
        phantom = derenzo_image(d, [4, 6, 8, 10, 12, 16], gap, arrowShape = true)

        phantomSize = size(phantom)

        @test phantom[
            Int(phantomSize[1] / 2)-10:Int(phantomSize[1] / 2)+9,
            Int(phantomSize[1] / 2)-10:Int(phantomSize[1] / 2)+9,
        ] == zeros(gap, gap)
        @test phantom[
            d+gap+1:d+gap+10,
            Int(phantomSize[1] / 2)-6:Int(phantomSize[1] / 2)+5,
        ] == ones(10, 12)

        # Use the previously generated derenzo phantom for the Jaszczak phantom
        jaszczak = jaszczak_phantom([6, 7, 8, 9, 10, 12], phantom, 120, 10, 50)

        @test size(jaszczak) == (phantomSize[1], phantomSize[2], 120)

        @test jaszczak[:, :, 50] == phantom
        @test jaszczak[
            Int(phantomSize[1] / 2)+28:Int(phantomSize[1] / 2)+43,
            Int(d / 2)-4:Int(d / 2)+11,
            70,
        ] == ones(16, 16)
    end

    @testset "spatial resolution phantom" begin
        # first call the function with inconsistent function arguments (the phantom should be too small for the specified holes)
        @test_throws ArgumentError(
            "Size of the phantom is too small to accommodate for desired hole size and number.",
        ) phantom = spatial_resolution_phantom((50, 50, 50), 5, [10])       # now too many rows are fit into a too small phantom size
        @test_throws ArgumentError(
            "Size of the phantom is too small to accommodate for desired hole size and number of rows.",
        ) phantom = spatial_resolution_phantom((50, 50, 50), 5, Int.(4 * ones(20)))

        phantom = spatial_resolution_phantom((300, 100, 50), 5, [10, 9, 8, 7, 6, 5, 4, 3])

        @test phantom[27:32, 8:13, 1:50] == ones(6, 6, 50)
        @test phantom[264, 59, 1:50] == ones(50)
    end

    @testset "Siemens star and spiral phantom" begin
        # siemens star phantom
        size = (81, 81)
        phantom = siemens_star(size)

        @test phantom[ceil(Int64, size[1] / 2)+4:size[1]-1, ceil(Int64, size[2] / 2)+1] ==
              ones(ceil(Int64, size[1] / 2) - 5)

        # the spiral phantom
        phantom = spiral()

        for x in [5, 15, 24, 34, 42]
            @test phantom[x, 42] == 1.0
        end
    end


    @testset "Four quadrant bar phantom" begin
        thickness = 4
        numBars = 4
        size = (140, 140)
        phantom = four_quadrant_bar(size, numBars = numBars, thickness = thickness)

        for i = 0:3
            y = 7 + i * 14
            # Note: the bars are always one pixel thicker than requested
            @test phantom[7:71, y:y+thickness] == ones(65, thickness + 1)
        end
    end

    @testset "Mixed Dot phantom" begin
        # The utility functions cannot easily be tested individually. 
        # They should be moved to a seperate file for including.
        smallRectWidth = 3
        mediumRectWidth = 4

        phantom = mixed_dot(
            82,
            (42, 44),
            ["SS", "CS"],
            [smallRectWidth, 5, 8, mediumRectWidth],
            (10, 9),
            distancesBetweenShapes = [(4, 4), (4, 3), (3, 3), (4, 4)],
            radiusOffset = (1.5, 1.85),
        )

        @test phantom[96:98, 96:98] == ones(smallRectWidth, smallRectWidth)
        @test phantom[66:69, 66:69] == ones(mediumRectWidth, mediumRectWidth)
    end
end
