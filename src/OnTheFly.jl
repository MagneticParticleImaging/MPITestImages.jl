
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

"""
https://en.wikipedia.org/wiki/Siemens_star
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

# Create a mixed dot phantom taken from Top et al. (2019)
@testimage_gen function mixed_dot(swidth::Integer=3, mwidth::Integer=4, lwidth::Integer=5, radius::Float64=3.5, numSquares::Integer=3)
	image = zeros(260,260)
  block = generateBlock(swidth, mwidth, lwidth, radius, numSquares)
  blockX = size(block,2)
  blockY = size(block,1)
  dist = 9

  for i in 0:3, j in 0:3
    offsetX = 33
    offsetY = 35
    image[offsetX+i*blockY+i*dist:offsetX+(i+1)*blockY+i*dist-1, offsetY+j*blockX+j*dist:offsetY+(j+1)*blockX+j*dist-1] = block
  end

  # Reduce image on the size 160x160
  image = image[46:end-54, 55:end-45]

  M = size(image,1)
  N = size(image,2)
  r = 82

  # Remove parts in blocks that range out of radius using the flood-fill algorithm
  for i in 1:M, j in 1:N
    if round(sqrt((i-78)^2+(j-80)^2)) > r
      if image[i,j] == 1
        flood_fill(image, (i,j))
      end
    end
  end

  # TODO: Fix this
  # Remove the rest...
  image[1:5, 44:105] .= 0
  image[20:28, 20:27] .= 0
  image[20:28, 20:27] .= 0
  image[4:12, 115:121] .= 0
  image[12:19, 124:130] .= 0
  image[46:54, 152:158] .= 0
  image[145:154, 38:44] .= 0
  image[32:39, 144:151] .= 0
  image[41:51, 1:8] .= 0
  image[151:158, 60:76] .= 0
  image[5:15, 30:42] .= 0

	return image
end

# Function that generates a complete block of small, medium and large squares and circles
function generateBlock(swidth, mwidth, lwidth, radius, numSquares)
	block = zeros(40,44)

	# Small squares
	dist = 4
	for i in 0:numSquares-1, j in 0:numSquares-1
		block[1+i*swidth+i*dist:(i+1)*swidth+i*dist, 2+j*swidth+j*dist:1+(j+1)*swidth+j*dist] .=1
	end

  # Medium squares
  dist = 4

  for i in 0:numSquares-1, j in 0:numSquares-1
		block[end-i*dist-(i+1)*mwidth+1:end-i*dist-i*mwidth, end-j*dist-(j+1)*mwidth:end-j*dist-j*mwidth-1] .=1
	end

	# Large squares
	distX = 3
	distY = 4

  for i in 0:numSquares-2, j in 0:numSquares-1
		block[1+i*lwidth+i*distY:(i+1)*lwidth+i*distY, end-j*distX-(j+1)*lwidth+1:end-j*distX-j*lwidth] .=1
	end

  # Circles
  centerX = 5
  centerY = size(block, 1)-15
  circle(block, centerX, centerY, radius)

  centerX = 15
  centerY = size(block,1)-15
  circle(block, centerX, centerY, radius)

  centerX = 5
  centerY = size(block,1)-5
  circle(block, centerX, centerY, radius)

  centerX = 15
  centerY = size(block,1)-5
  circle(block, centerX, centerY, radius)

  return block
end

function circle(block,centerX, centerY, radius)
  for i in -centerX:centerX
    for j in -centerX:centerX
      if sqrt(i^2+j^2) < radius
        block[centerY+i, centerX+j] = 1
      end
    end
  end
end

# Function describing the flood-fill algorithm used to remove certain parts of the blocks
function flood_fill(arr, (x, y))
  # check every element in the neighborhood of the element at (x, y) in arr
  for x_off in -1:1
    for y_off in -1:1
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
end
