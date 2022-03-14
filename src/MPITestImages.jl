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

onTheFlyImages = Vector{Symbol}()

"""
Add a function symbol to the list of known test image generation functions.
"""
function addOnTheFlyImage(fun::Symbol)
	if !(fun in onTheFlyImages)
		if !(fun in remotefiles)
			push!(onTheFlyImages, fun)
		else
			@warn "The on-the-fly image `$(string(fun))` is already linked with a remote file."
		end
	else
		error("The on-the-fly image `$(string(fun))` has already been added.")
	end
end

export testimage_gen
"""
Macro for annotating functions that can be used to generate test images.
"""
macro testimage_gen(expr::Expr)
	addOnTheFlyImage(expr.args[1].args[1]) # Note: use dump to debug expr
	return expr
end

export testimage
function testimage(name::String, args...; kwargs...)
	if Symbol(name) in onTheFlyImages # Prioritize on-the-fly images over file-based ones
		f = getfield(@__MODULE__, Symbol(name))
		return f(args...; kwargs...)
	elseif name in remotefiles
		rootpath = artifact"testimages"
		return load(joinpath(rootpath, "phantoms", name*".png"))
	else
		error("The given name `$name` did not match a known test image.")
	end
end

include("OnTheFly.jl")

end
