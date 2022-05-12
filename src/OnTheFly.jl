
export delta_image
"""
		$(SIGNATURES)

Function to generate a phantom with discrete points. The `distanceOfPoints` argument takes two functions
that take the number of the point to generate and return an integer. This makes the phantoms to generate highly 
customizable.

# Arguments
- `size::Tuple{Integer, Integer}`: The size of the phantom
- `numOfPoints::Integer`: The number of points to generate
- `sizeOfPoint::Tuple{Integer, Integer}`: The size of the points in the phantom
- `distanceOfPoints::Tuple{Function, Function}`: The distance to add between each points in x and y direction
- `pivot::Tuple{Integer, Integer}`: The starting point to generate points towards (size, size)
- `wrapPoint::Bool`: If true, points are generated in the next line or column if the border is reached
# Examples
```jldoctest
julia> image = delta_image((8, 8), 2; sizeOfPoint=(3, 2), distanceOfPoints=(x -> 0, x -> 4), pivot=(3, 3))
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
		distanceOfPoints::Tuple{Function, Function}=(x -> 1, x -> 1),	
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
			println("The function to calculate the distances is not valid.")
			return image
		end
 		
	end

	return image
end

export checker_image
"""
		$(SIGNATURES)

Function to generate a phantom with a checker board pattern. This function uses a best effort approach, meaning
that it is tried to cover most of the phantom with the pattern using the specified parameters.

# Arguments
- `size::Tuple{Integer, Integer}`: The size of the phantom
- `checkersCount::Tuple{Integer, Integer}`: How many squares to generate along each axis
- `stripeWidth::Tuple{Integer, Integer}`: By default `(1, 1)`. Sets the width of the lines between the squares

# Examples
```jldoctest
julia> image = checker_image((8, 8), (2, 3), (2, 1))
8×8 Matrix{Float64}:
 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
 0.0  1.0  0.0  1.0  0.0  1.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
 0.0  1.0  0.0  1.0  0.0  1.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
```
"""
@testimage_gen function checker_image(size::Tuple{Integer, Integer}=(8, 8), checkersCount::Tuple{Integer, Integer}=(2, 2), stripeWidth::Tuple{Integer, Integer}=(1, 1))	
	image = zeros(Float64, size)

	# Calculate the space of each square
	xSpace = convert(Integer, floor((size[1] - (checkersCount[1]+1)*stripeWidth[1]) / checkersCount[1]))
	ySpace = convert(Integer, floor((size[2] - (checkersCount[2]+1)*stripeWidth[2]) / checkersCount[2]))

	# Calculate the rest of the division that will be added to the border of the checker board
	xBorder = convert(Integer, round((size[1] - (checkersCount[1]+1)*stripeWidth[1] - xSpace * checkersCount[1]) / 2))
	yBorder = convert(Integer, round((size[2] - (checkersCount[2]+1)*stripeWidth[2] - ySpace * checkersCount[2]) / 2))

	# Generate the stripes
	for x in 0:checkersCount[1]-1
		for y in 0:checkersCount[2]-1
			image[xBorder+stripeWidth[1]+1+x*(xSpace+stripeWidth[1]):xBorder+x*(xSpace+stripeWidth[1])+xSpace+stripeWidth[1],
				  yBorder+stripeWidth[2]+1+y*(ySpace+stripeWidth[2]):yBorder+y*(ySpace+stripeWidth[2])+ySpace+stripeWidth[2]] .= 1
		end
	end

	return image
end