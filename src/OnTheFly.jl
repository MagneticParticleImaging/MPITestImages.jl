

@testimage_gen function three_dot_corner(size::Tuple{Integer, Integer}=(81,81))
	#TODO: Make more flexible 
	image = zeros(Float64, size)
	image[39:41, 39:41] .= 1
	image[39:41, 54:56] .= 1
	image[57:59, 39:41] .= 1
	return image
end

@testimage_gen function mixed_dot(size::Tuple{Integer, Integer}=(81,81))
	image = zeros(Float64, size)
	image[39:41, 39:41] .= 1
	image[39:41, 54:56] .= 1
	image[57:59, 39:41] .= 1
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