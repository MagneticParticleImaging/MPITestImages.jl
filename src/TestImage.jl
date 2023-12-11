export TestImage
"""
		$(SIGNATURES)

Struct describing a testimage.

# Fields
- `name::String`: The name of the test image.
- `data::AbstractArray`: The test image data itself. This can be 2D or 3D.
- `args::Tuple`: The arguments necessary to generate the specified test image.
- `kwargs::Any`: The corresponding key word arguments to generate the specified test image.
"""
struct TestImage
  name::String
  data::AbstractArray
  args::Tuple
  kwargs::Any

  function TestImage(name::String, args...; kwargs...)
    data = testimage(name, args...; kwargs...)
    return new(name, data, args, kwargs)
  end
end

export name
name(img::TestImage) = img.name

export data
data(img::TestImage) = img.data
