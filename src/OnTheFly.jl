

@testimage_gen function three_dot_corner(size::Tuple{Integer, Integer}=(81,81))
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