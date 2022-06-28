using ImageTransformations

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
- `circularShape::Bool`: If true, points are generated as circular
# Examples

## Two simple dots
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

## L-shaped arrangement
```jldoctest
julia> image = delta_image((8, 8), 3; sizeOfPoint=(2, 2), distanceOfPoints=(x -> x == 2 ? 3 : 0, x -> x == 3 ? -3 : 3), pivot=(3, 3))
8×8 Matrix{Float64}:
 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
 0.0  0.0  1.0  1.0  0.0  0.0  0.0  0.0
 0.0  0.0  1.0  1.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
 0.0  0.0  1.0  1.0  0.0  1.0  1.0  0.0
 0.0  0.0  1.0  1.0  0.0  1.0  1.0  0.0
 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
```
"""
@testimage_gen function delta_image(
		size::Tuple{Integer, Integer}, 
		numOfPoints::Integer; 
		sizeOfPoint::Tuple{Integer, Integer}=(1, 1),
		distanceOfPoints::Tuple{Function, Function}=(x -> 1, x -> 1),	
		pivot::Tuple{Integer, Integer}=(1, 1),
		circularShape::Bool=false
	)

	image = zeros(Float64, size)

	(xPos, yPos) = pivot

	# Calculate the pixels that will get filled
	shape = []
	if !circularShape || (sizeOfPoint[1] <= 2 && sizeOfPoint[2] <= 2)
		shape = ones(sizeOfPoint)
	else
		shape = zeros(sizeOfPoint)
		halfX = (sizeOfPoint[1] + 1) / 2
		halfY = (sizeOfPoint[2] + 1) / 2

		for x in 1:sizeOfPoint[1] 
			for y in 1:sizeOfPoint[2] 
				if ((x - halfX)^2/(halfX - 1.0)^2) + ((y - halfY)^2/(halfY - 1.0)^2) <= 1.25
					shape[x, y] = 1 
				end
			end
		end
	end

	for i in 1:numOfPoints
		if yPos + sizeOfPoint[2] > size[2] + 1 || xPos + sizeOfPoint[1] > size[1] + 1
			break
		end
		
		image[xPos:(xPos+sizeOfPoint[1] - 1), yPos:(yPos+sizeOfPoint[2] - 1)] = shape

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

export derenzo_image
"""
		$(SIGNATURES)

Function to generate Derenzo Phantom. This is done by specifying the radius of the phantom and the size in pixel for
each sextant of the phantom. The algorithm tries to fill the radius with as many dots as possible.

# Arguments
- `size::Tuple{Integer, Integer}`: Size of the phantom.
- `radius::Integer`: Radius of the circle generated.
- `pointSizePerSextant::Vector{Integer}`: Size for the points in each sextant. Should atleast be of length 6.

# Returns
- `image::Matrix{Float64}`: The resulting derenzo phantom.
"""
@testimage_gen function derenzo_image(imageSize::Tuple{Int64, Int64}, radius::Int64, pointSizePerSextant::Vector{Int64})
	# Check validity of params
	length(pointSizePerSextant) >= 6 || throw(ArgumentError("Invalid length of vector $pointSizePerSextant. Should atleast be 6!"))
	# if the points are too small, it would result in interpolation errors.
	minimum(pointSizePerSextant) >= 4 || throw(ArgumentError("Invalid size in $pointSizePerSextant. Should be atleast 4 pixels."))

	# Add maximum pointSize to accomodate points sitting on border
	width = Int(floor(2*tan(π/6)*radius) + maximum(pointSizePerSextant))
	l = Int(round(sqrt(radius^2 + width^2/4)))
	minimum(imageSize) > 2 * l || throw(ArgumentError("Invalid radius r: $radius for specified size: $size."))

	image = zeros(Int64, imageSize)
	(midX, midY) = Int.(round.((imageSize[1] / 2, imageSize[2] / 2)))

	# Compute Section size
	sectionSize = (radius, width)

	# compute for each sextant
	for numSextant in 1:6
		pointSize = pointSizePerSextant[numSextant]

		# Compute shape of dot in section
		shape = zeros((pointSize, pointSize))
		halfSize = (pointSize + 1) / 2		

		for x in 1:pointSize
			for y in 1:pointSize
				if ((x - halfSize)^2/(halfSize - 1.0)^2) + ((y - halfSize)^2/(halfSize - 1.0)^2) <= 1.0
					shape[x, y] = 1
				end
			end		
		end

		# middle of section
		shapesFit = width >= pointSize && radius >= pointSize
		numOfPoints = 1
		section = Int.(zeros(sectionSize))
		lastTopBottom = 1
		dist = 1
		while shapesFit	
			# compute distance (only once when two points are to be placed)
			if numOfPoints == 2
				while true
					widthAtRow = Int.(floor(2*tan(π/6)*(lastTopBottom+(dist-1)+halfSize)))
					spaceBetweenPoints = widthAtRow - 2*pointSize
				
					if dist == spaceBetweenPoints || dist >= radius
						break
					else
						dist += 1
					end
				end

				# Add point size, so points sit on border of cone
				dist += pointSize	
				lastTopBottom += (dist-1)

				if !(width >= numOfPoints * pointSize + dist * (numOfPoints-1) && radius >= pointSize + lastTopBottom)
					break
				end				
			end

			# fit numOfPoints shapes to matrix
			numZeros = width - pointSize*numOfPoints - dist*(numOfPoints-1)
			shapes = zeros(pointSize, Int(floor(numZeros/2)))
			shapes = hcat(shapes, shape)
			for num in 1:numOfPoints
				if numOfPoints == num
					shapes = hcat(shapes, zeros(pointSize, Int(ceil(numZeros/2))))
					break
				end

				distMatrix = zeros(pointSize, dist)
				shapes = hcat(shapes, distMatrix)
				shapes = hcat(shapes, shape)
			end

			section[lastTopBottom:lastTopBottom+pointSize-1, 1:end] = shapes
			lastTopBottom += pointSize + (dist - 50)

			# each row one more point
			numOfPoints += 1
		
			shapesFit = width >= numOfPoints * pointSize + dist * (numOfPoints-1) && radius >= pointSize + lastTopBottom
		end		

		# Putting sections together		
		spaceBetween = radius - lastTopBottom + dist
		offsetX = Int(round(spaceBetween / 2) + round(radius / 10))					
		rotatedImage = round.(imrotate(image, π/3), digits=4) 
		replace!(rotatedImage, NaN => 0.0)

		rotatedImage[midX+offsetX:midX+offsetX+radius-1, midY-Int(ceil(width/2)):midY+Int(floor(width/2))-1] += section

		image = rotatedImage
	end	

	# Constain image to specified size
	return image[1:imageSize[1], 1:imageSize[2]]
end