module MPITestImages

using Pkg.Artifacts
using FileIO

const remotefiles = [
	"Phantom1",
	"Phantom2",
	"Phantom3",
	"Phantom3_small",
	"phantom_2delta_notInLine_3px",
	"phantom_3delta_InLine_3px",
	"phantom_3delta_notInLine_3px",
	"phantom_brain_30",
	"phantom_checkers_4px",
	"phantom_delta_1px",
	"phantom_delta_3px",
	"phantom_delta_3px_shift1",
	"phantom_delta_3px_shift2",
	"phantom_vessel",
	"phantom_vessel2"
]

export testimage
function testimage(name::String)
	if name in remotefiles
		rootpath = artifact"testimages"
		return load(joinpath(rootpath, "phantoms", name*".png"))
	elseif name == "three_dot_corner"
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
