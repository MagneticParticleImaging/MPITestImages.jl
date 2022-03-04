module MPITestImages

using Pkg.Artifacts

const remotefiles = [
  
]

export testimage
function testimage(name::String)
	if name == "three_dot_corner"
		return three_dot_corner()
	else
		error("The given name `$name` did not match a known test image.")
	end
end


function three_dot_corner()
	image = zeros(Float64, (81, 81))
	image[39:41, 39:41] .= 1
	image[39:41, 54:56] .= 1
	image[57:59, 39:41] .= 1
	return image
end

end
