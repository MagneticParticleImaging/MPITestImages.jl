module MPITestImages

using DocStringExtensions
using Pkg.Artifacts
using FileIO
using Images
using MacroTools

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
    "phantom_vessel2",
]

onTheFlyImages = Vector{Symbol}()

"""
    $(SIGNATURES)

Add a function symbol to the list of known test image generation functions.
"""
function addOnTheFlyImage(fun::Symbol)
  if !(fun in onTheFlyImages)
    if !(string(fun) in remotefiles)
      push!(onTheFlyImages, fun)
    else
      @warn "The on-the-fly image `$(string(fun))` is already linked with a remote file but the on-the-fly variant will be priorized."
    end
  else
    error("The on-the-fly image `$(string(fun))` has already been added.")
  end
end

"""
    $(SIGNATURES)

Macro for annotating functions that can be used to generate test images.
"""
macro testimage_gen(expr::Expr)
  definitionDict = splitdef(expr)
  addOnTheFlyImage(definitionDict[:name])
  return expr
end

export testimage
"""
		$(SIGNATURES)

Retrieve a test image with the given `name` and the matching parameters.

Note: The name must correspond either to a remote file or a function
			name annotated by the `testimage_gen` macro. If both exist, precedence
			is given to the function.

# Examples
```jldoctest
julia> image = testimage("delta_image", (8, 8), 2; sizeOfPoint=(3, 2), distanceOfPoints=(x -> 0, x -> 4), pivot=(3, 3))
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
"""
function testimage(name::String, args...; kwargs...)
  if Symbol(name) in onTheFlyImages # Prioritize on-the-fly images over file-based ones
    f = getfield(@__MODULE__, Symbol(name))
    return f(args...; kwargs...)
  elseif name in remotefiles
    rootpath = artifact"testimages"

    try
      return changeScale(name, rootpath, args...)
    catch err
      if isa(err, MethodError)
        @warn "No scale provided. Using default image size."
      end
    end

    return load(joinpath(rootpath, "phantoms", name * ".png"))
  else
    error("The given name `$name` did not match a known test image.")
  end
end

"""
Loads the specified image from remote source and scales it accordingly.
"""
function changeScale(name::String, rootpath::String, size::Tuple{Integer, Integer}, args...)
  image = load(joinpath(rootpath, "phantoms", name * ".png"))

  return imresize(image, size)
end

include("TestImage.jl")
include("OnTheFly.jl")

end
