
@testimage_gen function three_dot_corner(size::Tuple{Integer, Integer}=(81,81))
	#TODO: Make more flexible 
	image = zeros(Float64, size)
	image[39:41, 39:41] .= 1
	image[39:41, 54:56] .= 1
	image[57:59, 39:41] .= 1
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