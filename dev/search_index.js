var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = MPITestImages","category":"page"},{"location":"#MPITestImages","page":"Home","title":"MPITestImages","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for MPITestImages.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [MPITestImages]","category":"page"},{"location":"#MPITestImages.TestImage","page":"Home","title":"MPITestImages.TestImage","text":"Struct describing a testimage.\n\n\n\n\n\n","category":"type"},{"location":"#MPITestImages.addOnTheFlyImage-Tuple{Symbol}","page":"Home","title":"MPITestImages.addOnTheFlyImage","text":"Add a function symbol to the list of known test image generation functions.\n\n\n\n\n\n","category":"method"},{"location":"#MPITestImages.changeScale-Tuple{String, String, Tuple{Integer, Integer}, Vararg{Any}}","page":"Home","title":"MPITestImages.changeScale","text":"Loads the specified image from remote source and scales it accordingly.\n\n\n\n\n\n","category":"method"},{"location":"#MPITestImages.checker_image","page":"Home","title":"MPITestImages.checker_image","text":"checker_image()\nchecker_image(size)\nchecker_image(size, checkersCount)\nchecker_image(size, checkersCount, stripeWidth)\n\n\nFunction to generate a phantom with a checker board pattern. This function uses a best effort approach, meaning that it is tried to cover most of the phantom with the pattern using the specified parameters.\n\nArguments\n\nsize::Tuple{Integer, Integer}: The size of the phantom\ncheckersCount::Tuple{Integer, Integer}: How many squares to generate along each axis\nstripeWidth::Tuple{Integer, Integer}: By default (1, 1). Sets the width of the lines between the squares\n\nExamples\n\njulia> image = checker_image((8, 8), (2, 3), (2, 1))\n8×8 Matrix{Float64}:\n 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0\n 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0\n 0.0  1.0  0.0  1.0  0.0  1.0  0.0  0.0\n 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0\n 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0\n 0.0  1.0  0.0  1.0  0.0  1.0  0.0  0.0\n 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0\n 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0\n\n\n\n\n\n","category":"function"},{"location":"#MPITestImages.delta_image-Tuple{Tuple{Integer, Integer}, Integer}","page":"Home","title":"MPITestImages.delta_image","text":"delta_image(size, numOfPoints; sizeOfPoint, distanceOfPoints, pivot, circularShape)\n\n\nFunction to generate a phantom with discrete points. The distanceOfPoints argument takes two functions that take the number of the point to generate and return an integer. This makes the phantoms to generate highly  customizable.\n\nArguments\n\nsize::Tuple{Integer, Integer}: The size of the phantom\nnumOfPoints::Integer: The number of points to generate\nsizeOfPoint::Tuple{Integer, Integer}: The size of the points in the phantom\ndistanceOfPoints::Tuple{Function, Function}: The distance to add between each points in x and y direction\npivot::Tuple{Integer, Integer}: The starting point to generate points towards (size, size)\ncircularShape::Bool: If true, points are generated as circular\n\nExamples\n\nTwo simple dots\n\njulia> image = delta_image((8, 8), 2; sizeOfPoint=(3, 2), distanceOfPoints=(x -> 0, x -> 4), pivot=(3, 3))\n8×8 Matrix{Float64}:\n 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0\n 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0\n 0.0  0.0  1.0  1.0  0.0  0.0  1.0  1.0\n 0.0  0.0  1.0  1.0  0.0  0.0  1.0  1.0\n 0.0  0.0  1.0  1.0  0.0  0.0  1.0  1.0\n 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0\n 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0\n 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0\n\nL-shaped arrangement\n\njulia> image = delta_image((8, 8), 3; sizeOfPoint=(2, 2), distanceOfPoints=(x -> x == 2 ? 3 : 0, x -> x == 3 ? -3 : 3), pivot=(3, 3))\n8×8 Matrix{Float64}:\n 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0\n 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0\n 0.0  0.0  1.0  1.0  0.0  0.0  0.0  0.0\n 0.0  0.0  1.0  1.0  0.0  0.0  0.0  0.0\n 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0\n 0.0  0.0  1.0  1.0  0.0  1.0  1.0  0.0\n 0.0  0.0  1.0  1.0  0.0  1.0  1.0  0.0\n 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0\n\n\n\n\n\n","category":"method"},{"location":"#MPITestImages.testimage-Tuple{String, Vararg{Any}}","page":"Home","title":"MPITestImages.testimage","text":"testimage(name, args; kwargs...)\n\n\nRetrieve a test image with the given name and the matching parameters.\n\nNote: The name must correspond either to a remote file or a function  \t\t\tname annotated by the testimage_gen macro. If both exist, precedence \t\t\tis given to the function.\n\nExamples\n\njulia> image = testimage(\"delta_image\", (8, 8), 2; sizeOfPoint=(3, 2), distanceOfPoints=(x -> 0, x -> 4), pivot=(3, 3))\n8×8 Matrix{Float64}:\n 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0\n 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0\n 0.0  0.0  1.0  1.0  0.0  0.0  1.0  1.0\n 0.0  0.0  1.0  1.0  0.0  0.0  1.0  1.0\n 0.0  0.0  1.0  1.0  0.0  0.0  1.0  1.0\n 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0\n 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0\n 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0\n\n\n\n\n\n","category":"method"},{"location":"#MPITestImages.@testimage_gen-Tuple{Expr}","page":"Home","title":"MPITestImages.@testimage_gen","text":"Macro for annotating functions that can be used to generate test images.\n\n\n\n\n\n","category":"macro"}]
}