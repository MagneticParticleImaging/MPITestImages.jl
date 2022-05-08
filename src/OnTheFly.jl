

"""
Function to generate a phantom with discrete points. The `distanceOfPoints` argument takes two functions
that take the number of the point to generate and return an integer. This makes the phantoms to generate highly 
costumizable.

# Arguments
- `size::Tuple{Integer, Integer}`: The size of the phantom
- `numOfPoints::Integer`: The number of points to generate
- `sizeOfPoint::Tuple{Integer, Integer}`: The size of the points in the phantom
- `distanceOfPoints::Tuple{Function, Function}`: The distance to add between each points in x and y direction
- `pivot::Tuple{Integer, Integer}`: The starting point to generate points towards (size, size)
- `wrapPoint::Bool`: If true, points are generated in the next line or column if the border is reached
# Examples
```jldoctest
julia> image = delta_image((8, 8), 2; 
			sizeOfPoint=(3, 2), 
			distanceOfPoints=(function (x) return 0 end, function (x) return 4 end), 
			pivot=(3, 3))
```
```jldoctest
8×8 Matrix{Float64}:
	0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
	0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
	0.0  0.0  1.0  1.0  0.0  0.0  1.0  1.0
	0.0  0.0  1.0  1.0  0.0  0.0  1.0  1.0
	0.0  0.0  1.0  1.0  0.0  0.0  1.0  1.0
	0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
	0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
	0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
```
"""
@testimage_gen function delta_image(
	size::Tuple{Integer, Integer}, 
	numOfPoints::Integer; 
	sizeOfPoint::Tuple{Integer, Integer}=(1, 1),
	distanceOfPoints::Tuple{Function, Function}=(function (x) return x end, function (x) return x end),	
	pivot::Tuple{Integer, Integer}=(1, 1)
	)

	image = zeros(Float64, size)

	(xPos, yPos) = pivot

	for i in 1:numOfPoints
		if yPos + sizeOfPoint[2] > size[2] + 1 || xPos + sizeOfPoint[1] > size[1] + 1
			break
		end

		image[xPos:(xPos+sizeOfPoint[1] - 1), yPos:(yPos+sizeOfPoint[2] - 1)] .= 1

		try
			xPos += distanceOfPoints[1](i+1)
			yPos += distanceOfPoints[2](i+1)
		catch
			println("The Function to calculate the distances is not valid")
			return image
		end
 		
	end

	return image
end

