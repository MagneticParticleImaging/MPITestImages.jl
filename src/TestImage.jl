export TestImage
"""
Struct describing a testimage.
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