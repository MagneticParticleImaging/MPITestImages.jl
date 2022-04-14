

@testimage_gen function three_dot_corner(size::Tuple{Integer, Integer}=(81,81))
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
	return image
end