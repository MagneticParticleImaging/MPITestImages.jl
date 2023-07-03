
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

Function to generate Derenzo Phantom. This is done by specifying the diameter of the phantom and the size in pixel and 
for each sextant of the phantom. The algorithm tries to fill the radius with as many dots as possible.

# Arguments
- `diameter::Int64`: Diameter in pixel of the phantom.
- `pointSizePerSextant::Vector{Integer}`: Size for the points in each sextant. Should atleast be of length 6.
- `gapBetweenSextants::Union{Int64, Vector{Int64}}`: Gap between the center of the phantom and the sextants.

# Optional Arguments
`distanceBetweenPoints::Union{Int64, Vector{Int64}}=-1`: The ctc distance of the holes. 
`arrowShape::Bool=false`: If true the last row of each sextant will have another row of one less hole if it fits.

# Returns
- `image::Matrix{Float64}`: The resulting Derenzo phantom.

# Examples
This call generates a phantom similar to QRMs Mini Derenzo Phantom:
```
derenzo = derenzo_image(600, 
	Int.(round.([0.6*500, 0.8*500, 1.0*500, 1.2*500, 1.5*500, 2.0*500]./29)), 
	30,
	distanceBetweenPoints=Int.(round.([1.2*500, 1.6*500, 2.0*500, 2.4*500, 3.0*500, 4.0*500]./29)),
	arrowShape=true)
```
"""
@testimage_gen function derenzo_image(diameter::Int64, pointSizePerSextant::Vector{Int64}, gapBetweenSextants::Union{Int64, Vector{Int64}}; distanceBetweenPoints::Union{Int64, Vector{Int64}}=-1, arrowShape::Bool=false)
	# Check validity of params
	length(pointSizePerSextant) >= 6 || throw(ArgumentError("Invalid length of vector $pointSizePerSextant. Should atleast be 6!"))
	(gapBetweenSextants isa Vector{Int64} && length(gapBetweenSextants) < 6) && throw(ArgumentError("Invalid length of vector $gapBetweenSextants. Should atleast be 6 or a scalar!"))
	# if the points are too small, it would result in interpolation errors.
	minimum(pointSizePerSextant) >= 4 || throw(ArgumentError("Invalid size in $pointSizePerSextant. Should be atleast 4 pixels."))

	# calculate radius and width
	radius = round(Int, (diameter - 2*maximum(gapBetweenSextants)) / 2) + Int(ceil(maximum(pointSizePerSextant)/2))
	width(r) = Int(floor(2*tan(π/6)*r))
	widthSextant = width(radius) 

	# Add to radius if we want arrow shape
	if arrowShape 
		radius += (distanceBetweenPoints == -1 ? maximum(pointSizePerSextant) : maximum(distanceBetweenPoints)) + maximum(pointSizePerSextant)
	end

	# Compute sextant size
	sextantSize = (radius, widthSextant)

	# Create final image with correct dimensions
	l = 2*Int(round(sqrt(radius^2 + widthSextant^2/4)) + maximum(pointSizePerSextant) + maximum(gapBetweenSextants))
	image = zeros(Int64, (l, l))
	midImage = Int(round(l / 2))

	# Compute each sextant and add to image
	for numSextant in 1:6
		# Create the shape according to pointSizePerSextant
		pointSize = pointSizePerSextant[numSextant]

		shape = zeros((pointSize, pointSize))
		halfSize = pointSize / 2		

		for x in 1:pointSize
			for y in 1:pointSize
				if ((x - halfSize - 0.5)^2/(halfSize-0.5)^2) + ((y - halfSize - 0.5)^2/(halfSize - 0.5)^2) <= 1.0
					shape[x, y] = 1
				end
			end		
		end

		# Initialize variables
		horiDist = 0		# The horizontal distance between the holes
		vertDist = 0		# The vertical distance between the holes
		lastHoleTop = 1	# The height of the center of the last row of holes
		numOfPoints = 1		# How many points to place in this row
		sextant = zeros(Int64, sextantSize)	# The sextant to place the holes in
		shapesFit = true	# Boolean to determine if more holes fit in sextant
		widthReached = false # When arrow shape is desired determines when last row was added

		while shapesFit
			# Calculate the distances
			horiDist = 2*(distanceBetweenPoints == -1 ? pointSize : (distanceBetweenPoints isa Vector{Int64} ? distanceBetweenPoints[numSextant] : distanceBetweenPoints))
			vertDist = round(Int64, sqrt(horiDist^2 - horiDist^2/4))
			
			# fit numOfPoints shapes to matrix
			numZeros = widthSextant - pointSize*numOfPoints - (horiDist - pointSize)*(numOfPoints-1)
			shapes = zeros(pointSize, Int(floor(numZeros/2)))
			shapes = hcat(shapes, shape)
			for num in 1:numOfPoints
				if numOfPoints == num
					shapes = hcat(shapes, zeros(pointSize, Int(ceil(numZeros/2))))
					break
				end

				distMatrix = zeros(pointSize, (horiDist - pointSize))
				shapes = hcat(shapes, distMatrix)
				shapes = hcat(shapes, shape)
			end

			# Fit shape in the right row of sextant
			if radius >= pointSize + lastHoleTop
				sextant[lastHoleTop:lastHoleTop+pointSize-1, 1:end] = shapes
				lastHoleTop += vertDist
			end

			# each row one more point
			numOfPoints += 1

			shapesFitHorizontally = widthSextant >= numOfPoints * pointSize + (horiDist - pointSize)*(numOfPoints-1) 
			shpesFitVertically = radius >= pointSize + lastHoleTop

			if !shapesFitHorizontally && arrowShape && !widthReached
				numOfPoints -= 2
				shapesFit = true
				widthReached = true
			else
				shapesFit = shapesFitHorizontally && shpesFitVertically && !widthReached
			end
		end		
		# Putting sextants together	
		# calculate space between last row of points and edge of sextant	
		spaceBetween = gapBetweenSextants == -1 ? radius - lastHoleTop + (vertDist - pointSize) : (gapBetweenSextants isa Vector{Int64} ? gapBetweenSextants[numSextant] : gapBetweenSextants)
		offsetX = Int(round(spaceBetween / 2) + spaceBetween)					
		rotatedImage = round.(imrotate(image, π/3), digits=4) 
		replace!(rotatedImage, NaN => 0.0)

		rotatedImage[midImage+offsetX:midImage+offsetX+radius-1, midImage-Int(ceil(widthSextant/2)):midImage+Int(floor(widthSextant/2))-1] += sextant

		image = rotatedImage	
	end

	# Constrain image to specified size
	return image[1:l, 1:l]
end

export jaszczak_phantom
"""
		$(SIGNATURES)

Function to generate the Jaszczak Phantom. It is necessary to generate a Derenzo phantom first as it is part of the 3D body to generate.

# Arguments
- `radiusSpheres::Vector{Int64}`: Vector with length 6 giving the radius of each sphere of the phantom.
- `derenzoImage::Matrix{Float64}`: The Derenzo phantom which is part of the Jaszczak Phantom. 
The dimensions of this image dictates the depth and width of the resulting phantom.
- `height::Int64`: The height of the phantom.
- `distanceSpheresToRods::Int64`: The distance between the spheres and the beginning of the rods.
- `heightRods::Int64`: The height of the rods (The Derenzo phantom part).

# Returns
- `Array{Float64, 3}`: The three dimensional phantom.
"""
@testimage_gen function jaszczak_phantom(radiusSpheres::Vector{Int64}, derenzoImage::Matrix{Float64}, height::Int64, distanceSpheresToRods::Int64, heightRods::Int64)
	length(radiusSpheres) >= 6 || throw(ArgumentError("Invalid length of vector $radiusSpheres. Should atleast be 6!"))

	sliceSize = size(derenzoImage)
	distanceSpheresToCenter = round(Int64, sliceSize[1] / 4)
	maxSphereHeight = Int(2*maximum(radiusSpheres))
	(maxSphereHeight < distanceSpheresToCenter / 2 && maxSphereHeight < height - distanceSpheresToRods - heightRods) || throw(ArgumentError("Radius of spheres too big for given derenzo image and height."))
	sphereSlice = zeros(sliceSize[1], sliceSize[2], maxSphereHeight)

	for sphere in 1:6
		radius = radiusSpheres[sphere]
		shape = zeros(Int.((2*radius, 2*radius, 2*radius)))
		
		# Create Sphere
		for x in 1:2*radius
			for y in 1:2*radius
				for z in 1:2*radius
					if ((x - radius - 0.5)^2/(radius-0.5)^2) + ((y - radius - 0.5)^2/(radius - 0.5)^2) + ((z - radius - 0.5)^2/(radius - 0.5)^2) <= 1.0
						shape[x, y, z] = 1
					end
				end
			end		
		end
		
		# Place sphere in correct position		
		x = 2*distanceSpheresToCenter + round(Int64, distanceSpheresToCenter * cos((sphere - 1) * π/3))
		y = 2*distanceSpheresToCenter + round(Int64, distanceSpheresToCenter * sin((sphere - 1) * π/3))
		z = round(Int64, maxSphereHeight/2)

		sphereSlice[x-radius+1:x+radius, y-radius+1:y+radius, z-radius+1:z+radius] .= shape
	end

	# Stack derenzo phantoms
	sliceRods = Array{Float64}(undef, sliceSize[1], sliceSize[2], heightRods)
	for i=1:heightRods
		sliceRods[:, :, i] .= derenzoImage
	end

	# combine everything
	result = zeros(sliceSize[1], sliceSize[2], height)
	result[:, :, 1:heightRods] .= sliceRods
	result[:, :, heightRods+distanceSpheresToRods:heightRods+distanceSpheresToRods+maxSphereHeight-1] .= sphereSlice
	
	return result
end

export spatial_resolution_phantom
"""
		$(SIGNATURES)

Generates Spatial Resolution Phantom.

Adapted from https://www.elsesolutions.com/wp-content/uploads/2016/02/Spatial-Resolution-Phantom.pdf

# Arguments
- `size::Tuple{Integer, Integer, Integer}`: The size of the 3D phantom.
- `numHolesInRow::Integer`: How many holes should be placed in one row.
- `holeSizes::Vector{Integer}`: Sizes of holes at each row. The length of this vector is also indicative of the amount of rows in the phantom.

# Returns
- `Array{Float64, 3}`: The three dimensional phantom.
"""
@testimage_gen function spatial_resolution_phantom(sizePhantom::Tuple{Int64, Int64, Int64}, numHolesInRow::Int64, holeSizes::Vector{Int64})
	# as many rows, as specified in vector
	numRows = length(holeSizes)

	# Calculate gaps and borders and verify arguments
	maxHoleSize = maximum(holeSizes)
	border = round(Integer, (sizePhantom[2] - 2*numHolesInRow*maxHoleSize + maxHoleSize) / 2)
	border < 1 && throw(ArgumentError("Size of the phantom is too small to accommodate for desired hole size and number."))

	yDist = floor(Integer, (sizePhantom[1] - numRows*maxHoleSize) / (numRows + 1))
	yDist < 1 && throw(ArgumentError("Size of the phantom is too small to accommodate for desired hole size and number of rows."))

	# Create phantom
	slice = zeros(yDist, sizePhantom[2])

	# Fit holes in phantom
	for row in 1:numRows
		# Create hole shape
		holeSize = holeSizes[row]

		shape = zeros((maxHoleSize, maxHoleSize))
		halfSize = holeSize / 2		

		for x in 1:holeSize
			for y in 1:holeSize
				if ((x - halfSize - 0.5)^2/(halfSize-0.5)^2) + ((y - halfSize - 0.5)^2/(halfSize - 0.5)^2) <= 1.0
					shape[x, y] = 1
				end
			end		
		end

		# Create row
		rowShape = zeros((maxHoleSize, border))
		rowShape = hcat(rowShape, shape)
		for hole in 1:(numHolesInRow - 1) 
			rowShape = hcat(rowShape, zeros(maxHoleSize, holeSize))
			rowShape = hcat(rowShape, shape)
		end
		rowShape = hcat(rowShape, zeros((maxHoleSize, sizePhantom[2] - size(rowShape)[2])))

		slice = vcat(slice, rowShape)
		slice = vcat(slice, zeros(yDist, sizePhantom[2]))
	end

	# Fill rest of slice in case of rounding issues
	if size(slice, 1) < sizePhantom[1]
		slice = vcat(slice, zeros(sizePhantom[1]-size(slice, 1), sizePhantom[2]))
	end

	# Stack the slices
	phantom = Array{Float64}(undef, sizePhantom)
	for i=1:sizePhantom[3]
		phantom[:, :, i] .= slice
	end

	return phantom
end										

export siemens_star
"""
		$(SIGNATURES)

This function generates a siemens star phantom, also known as spoke target. 

# Arguments 
- `size::Tuple{Integer, Integer}`: The size of the phantom in pixel.
# Optional Arguments 
- `numSpokes::Integer=8`: The number of spokes pointing to the center of the phantom.
# Returns 
- `Matrix{Float64}`: The resulting image. 
"""
@testimage_gen function siemens_star(size::Tuple{Integer, Integer}=(81,81); numSpokes::Integer=8)
	radius = minimum(size)/2
	Drawing(size..., :image)
	origin()
	background("black")
	sethue("white")

	spokeAngle = π/numSpokes
	for spokeIdx in 1:numSpokes
		Luxor.pie(radius, (2*spokeIdx-1)*spokeAngle, (2*spokeIdx)*spokeAngle, :fill)
	end

	image = Float32.(Gray.(image_as_matrix()))
  finish()

	return image
end

export spiral
"""
		$(SIGNATURES)

This function generates a spiral phantom. The spiral spirals around the center of the image. 

# Arguments 
- `size::Tuple{Integer, Integer}`: The size of the phantom in pixel.
# Optional Arguments 
- `numTurn::Real=8`: The number of turns of the spiral around the center of the image. 
- `thickness::Real=2`: The thickness of the spiral.  
# Returns 
- `Matrix{Float64}`: The resulting image. 
"""
@testimage_gen function spiral(size::Tuple{Integer, Integer}=(81,81); numTurns::Real=4, thickness::Real=2)
	radius = minimum(size)/2
	Drawing(size..., :image)
	origin()
	background("black")
	sethue("white")
	setline(thickness)
	Luxor.spiral(radius/numTurns/(2π)*0.95, 1, log=false, period=numTurns*2π, :stroke)

	image = Float32.(Gray.(image_as_matrix()))
  finish()

	return image
end

export four_quadrant_bar
"""
		$(SIGNATURES)

This function generates an image with four quadrants. In each quadrant a specified number of bars with a specified thickness 
are generated. 

# Arguments
- `size::Tuple{Integer, Integer}`: The size of the phantom in pixel.
# Optional Arguments 
- `numBars::Real=8`: The number of bars to generate in one quadrant. 
- `thickness::Real=2`: The thickness of one bar. Note, that this is always 1 pixel larger than specified.
# Returns 
- `Matrix{Float64}`: The resulting image. 

# Examples
```
julia> four_quadrant_bar((18, 18), numBars=2, thickness=0)
18×18 Matrix{Float32}:
 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
 0.0  1.0  0.0  0.0  0.0  1.0  0.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  0.0  0.0
 0.0  1.0  0.0  0.0  0.0  1.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
 0.0  1.0  0.0  0.0  0.0  1.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
 0.0  1.0  0.0  0.0  0.0  1.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
 0.0  1.0  0.0  0.0  0.0  1.0  0.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  0.0  0.0
 0.0  1.0  0.0  0.0  0.0  1.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
 0.0  1.0  0.0  0.0  0.0  1.0  0.0  0.0  0.0  0.0  0.0  1.0  0.0  0.0  0.0  1.0  0.0  0.0
 0.0  1.0  0.0  0.0  0.0  1.0  0.0  0.0  0.0  0.0  0.0  1.0  0.0  0.0  0.0  1.0  0.0  0.0
 0.0  1.0  0.0  0.0  0.0  1.0  0.0  0.0  0.0  0.0  0.0  1.0  0.0  0.0  0.0  1.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  1.0  0.0  0.0  0.0  1.0  0.0  0.0
 0.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  0.0  1.0  0.0  0.0  0.0  1.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  1.0  0.0  0.0  0.0  1.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  1.0  0.0  0.0  0.0  1.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  1.0  0.0  0.0  0.0  1.0  0.0  0.0
 0.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  0.0  1.0  0.0  0.0  0.0  1.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
```
"""
@testimage_gen function four_quadrant_bar(size::Tuple{Integer, Integer}=(81,81); numBars::Real=4, thickness::Real=2)
	image = zeros(Float32, size)

	length = round(Int64, size[1]/2.2)
	dist = round(Int64, (size[1]/2-(numBars-1)*thickness)/(numBars-0)/2)

	for i in 1:numBars
		@inbounds image[dist:dist+length, (2*i-1)*dist:(2*i-1)*dist+thickness] .= 1
	end

	for i in 1:numBars
		@inbounds image[end-dist-length:end-dist, end-(2*i-1)*dist-thickness:end-(2*i-1)*dist] .= 1
	end

	length = round(Int64, size[2]/2.2)
	dist = round(Int64, (size[2]/2-(numBars-1)*thickness)/(numBars-0)/2)

	for i in 1:numBars
		@inbounds image[end-(2*i-1)*dist-thickness:end-(2*i-1)*dist, dist:dist+length] .= 1
	end

	for i in 1:numBars
		@inbounds image[(2*i-1)*dist:(2*i-1)*dist+thickness, end-dist-length:end-dist] .= 1
	end

	return image
end

# Function describing the flood-fill algorithm used to remove certain parts of the blocks
function flood_fill(arr, (x, y))
	# check every element in the neighborhood of the element at (x, y) in arr
	for x_off in -1:1, y_off in -1:1
		# put the next part in a try-catch block so that if any index
		# is outside the array, we move on to the next element.
		try
			# if the element is a 1, change it to a 0 and call flood_fill
			# on it so it fills it's neighbors
			if arr[x + x_off, y + y_off] == 1
				arr[x + x_off, y + y_off] = 0
				flood_fill(arr, (x + x_off, y + y_off))
			end
		catch
			continue
		end
	end
end


export mixed_dot
"""
		$(SIGNATURES)

This function generates a mixed dot phantom as implemented by Top et al. (2019). 

The phantom can be specified to consists of a mixed arrangement of circles and squares with different sizes. 
The order of these shapes can also be specified. The arrangement of shapes is again arranged in a higher-level rectangular shape. 
These are repeated according to the specified radius and finally fitted into a circle. 

# Arguments
- `radius::Integer`: The radius of the higher level circle. This can be regarded as the image size.
- `blockSize::Tuple{Integer, Integer}`: The size of the rectangular blocks that make up the phantom. 
- `blockPattern::Vector{String}`: This vectors describes the pattern of one block in the phantom. Each element constitutes to a line in the 
block. The shapes can be specified by the letter `"S"` for a square and `"C"` for a circle.
- `shapeSizes::Vector{Int}`: This vector describes the size of the shapes specified by `blockPattern`. For a circle the size is interpreted as the diameter, where as
for the square shape, the size is the width. 
- `distanceBetweenBlocks::Tuple{Integer, Integer}`: This specifies the distance between the blocks in x and y direction. 

# Optional Arguments
- `distancesBetweenShapes::Union{Vector{Tuple{Integer, Integer}}, Missing}`: Optionally, the distance between the shapes within the blocks can also be specified in x and y direction. If not set, 
the distance between the shapes is assumed to be the size as specified with `shapeSizes` for x and y equally. 
- `radiusOffset::Tuple{Integer, Integer}`: This applies an offset in x and y direction to the radius of the higher level circle.

# Returns 
- `Matrix{Float64}`: The resulting image. 

# Example
The following function call generates a phantom as specified by Top et al. (2019).

```
phantom = mixed_dot(82, (42, 44), ["SS", "CS"], [3, 5, 8, 4], (10, 9), distancesBetweenShapes=[(4, 4), (4, 3), (3, 3), (4, 4)], radiusOffset=(1.5, 1.85))
```
"""
@testimage_gen function mixed_dot(radius::Integer, blockSize::Tuple{Integer, Integer}, blockPattern::Vector{String}, shapeSizes::Vector{Int}, distanceBetweenBlocks::Tuple{Integer, Integer}; distancesBetweenShapes::Union{Vector{Tuple{Int, Int}}, Missing}=missing, radiusOffset::Tuple{Float64, Float64}=(0,0))
	block = createBlock(blockSize, blockPattern, shapeSizes, distances=distancesBetweenShapes)
	block = hcat(block, zeros(blockSize[1], distanceBetweenBlocks[2]))
	block = vcat(block, zeros(distanceBetweenBlocks[1], blockSize[2] + distanceBetweenBlocks[2]))

	repeatX = ceil(Int64, radius*2 / size(block)[1]) 
	repeatY = ceil(Int64, radius*2 / size(block)[2])

	# the created image will be larger than specified
	image = repeat(block, repeatX, repeatY)	

	# center image correctly and create circle
	imageCenter = floor.(Int64, (size(image)[1] / 2 - distanceBetweenBlocks[1] / 2, size(image)[2] / 2 - distanceBetweenBlocks[2] / 2))
	
	idxToCut = Vector{Tuple{Int64, Int64}}(undef, 0)
	for x in -imageCenter[1]+1:imageCenter[1], y in -imageCenter[2]+1:imageCenter[2]
		if round(sqrt((x + radiusOffset[1])^2 + (y + radiusOffset[2])^2)) > radius
			# if pixel just outside radius and are one
			if round(sqrt((x + radiusOffset[1])^2 + (y + radiusOffset[2])^2)) <= radius + 1 && image[x + imageCenter[1], y + imageCenter[2]] == 1
				push!(idxToCut, (x + imageCenter[1], y + imageCenter[2]))
			end
			image[x + imageCenter[1], y + imageCenter[2]] = 0
		end
	end

	xGap = abs(radius - imageCenter[1])
	yGap = abs(radius - imageCenter[2])	

	# cut out incomplete shapes using flood fill
	for idx in idxToCut
		flood_fill(image, idx)
	end

	# contrain image to specified size
	image = image[xGap:imageCenter[1]+radius+1-floor(Int64, distanceBetweenBlocks[1]/2), yGap:imageCenter[2]+radius+1-floor(Int64, distanceBetweenBlocks[2]/2)]

	return image
end

function createBlock(blockSize::Tuple{Integer, Integer}, pattern::Vector{String}, sizes::Vector{Int}; distances::Union{Vector{Tuple{Int, Int}}, Missing}=missing)
	numShapes = sum(length.(pattern))
	numShapes == length(sizes) || throw(ArgumentError("For the specified pattern, the right amount of sizes was not given. It was $(length(sizes)) and should be $(numShapes)"))
	if !ismissing(distances) numShapes == length(distances) || throw(ArgumentError("For the specified pattern, the right amount of distances was not given. It was $(length(distances)) and should be $(numShapes)")) end
	block = zeros(blockSize)

	# number of different shapes to put in block
	numRows = length(pattern)

	# devide block size
	xSpace = floor(Int64, blockSize[1] / numRows)
	shapeCounter = 0

	for row in 1:numRows	
		p = pattern[row]

		# calc space in y direction for each shape
		ySpace = floor(Int64, blockSize[2] / length(p))
		for col in eachindex(p)
			shapeCounter += 1
			shapeIndicator = p[col]

			shapeSize = sizes[shapeCounter]
			shape = zeros(shapeSize, shapeSize)
			# select the correct shape
			if shapeIndicator == 'S'
				shape = shape .+ 1
			elseif shapeIndicator == 'C'
				radius = (shapeSize - 1) / 2
				center = floor(Int64, shapeSize / 2)

				for x in -center:center, y in -center:center
					if sqrt(x^2 + y^2) < radius
						shape[center + x, center + y] = 1
					end
				end
			end

			shapeSize >= minimum(blockSize) && throw(ArgumentError("The block is too small to accommodate the shapes!"))

			# define borders
			pivot = (xSpace*(row - 1)+1, ySpace*(col - 1)+1)

			# if no distances are provided use size of shapes as default distance
			dist = ismissing(distances) ? (sizes[shapeCounter], sizes[shapeCounter]) : distances[shapeCounter]	

			x, y = 0, 0

			itFits = true
			while itFits
				block[pivot[1]+x:pivot[1]+x+shapeSize-1, 
					  pivot[2]+y:pivot[2]+y+shapeSize-1] .= shape

				y += shapeSize + dist[2]

				if y+shapeSize >= ySpace
					y = 0
					x += shapeSize + dist[1]
					if x + shapeSize >= xSpace
						itFits = false
					end
				end
			end
		end
	end

	return block
end 


export sine_bar_phantom
"""
		$(SIGNATURES)

This function generates specified number of bars along a specified direction. These bars have varying intensity according to 
a sine wave. 

# Arguments
- `size::Tuple{Integer, Integer}`: The size of the phantom in pixel.
# Optional Arguments 
- `N::Real=3`: The number of bars to generate. This does not have to be an integer.
- `direction::String`: This can either be `"X"` or `"Y"` for the orientation of the bars.
- `phase::Real`: The phase of the sine wave.
# Returns 
- `Matrix{Float64}`: The resulting image. 
"""
@testimage_gen function sine_bar_phantom(size::Tuple{Integer, Integer}=(81,81); N=3, direction="X", phase=1.5π)
	if direction == "X"
		image = repeat(sin.(range(0, 2π*N, length=size[1]+1)[1:end-1] .+ phase), 1, size[2])'
	elseif direction == "Y"
		image = repeat(sin.(range(0, 2π*N, length=size[1]+1)[1:end-1] .+ phase), 1, size[2])
	else
		error("Direction `$direction` not valid.")
	end

	return image.*0.5.+0.5 # Shift to interval [0, 1]
end