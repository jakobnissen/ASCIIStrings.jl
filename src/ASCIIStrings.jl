module ASCIIStrings

export ASCIIString

struct Unsafe end
const unsafe = Unsafe()

"""
    ASCIIString <: AbstractString

A string type that can only contain ASCII characters.

# Examples
```julia
julia> s = ASCIIString("Abracadabra!")
"Abracadabra!"

julia> ASCIIString("это не работает")
ERROR: String is not ASCII
[...]
```
"""
struct ASCIIString <: AbstractString
    x::String

    ASCIIString(::Unsafe, s::String) = new(s)
end

ASCIIString(s::String) = isascii(s) ? ASCIIString(unsafe, s) : error("String is not ASCII")
ASCIIString(s::AbstractString) = ASCIIString(String(s))
Base.String(s::ASCIIString) = s.x

# AbstractString interface
Base.ncodeunits(s::ASCIIString) = ncodeunits(s.x)
Base.codeunit(::ASCIIString) = UInt8

Base.@propagate_inbounds function Base.codeunit(s::ASCIIString, i::Integer)
    codeunits(s.x)[i]
end

function Base.iterate(s::ASCIIString, i::Int=1)
    i > ncodeunits(s) ? nothing : (@inbounds s[i], i + 1)
end

# Other functions
Base.reverse(s::ASCIIString) = ASCIIString(unsafe, String(reverse(codeunits(s))))

# Optimised functions
Base.isascii(::ASCIIString) = true
Base.cmp(a::ASCIIString, b::ASCIIString) = cmp(String(a), String(b))
Base.length(s::ASCIIString) = ncodeunits(s)
Base.nextind(::ASCIIString, i::Int) = i + one(i)
Base.prevind(::ASCIIString, i::Int) = i - one(i)
Base.isvalid(s::ASCIIString, i::Int) = 0 < i ≤ length(s)

Base.@propagate_inbounds function Base.thisind(s::ASCIIString, i::Int)
    @boundscheck isvalid(s, i) || throw(BoundsError(s, i))
    i
end

Base.@propagate_inbounds function Base.getindex(s::ASCIIString, i::Integer)
    @boundscheck checkbounds(s, i)
    @inbounds reinterpret(Char, (codeunit(s, i) % UInt32) << 24)
end

function Base.uppercase(s::ASCIIString)
    v = Vector{UInt8}(undef, ncodeunits(s))
    @inbounds for i in eachindex(v)
        b = codeunit(s, i) - UInt8('a')
        v[i] = b - ((b < UInt8(26)) * 0x20) + UInt8('a')
    end
    ASCIIString(unsafe, String(v))
end

function Base.lowercase(s::ASCIIString)
    v = Vector{UInt8}(undef, ncodeunits(s))
    @inbounds for i in eachindex(v)
        b = codeunit(s, i) - UInt8('A')
        v[i] = b + ((b < UInt8(26)) * 0x20) + UInt8('A')
    end
    ASCIIString(unsafe, String(v))
end

end # module AsciiStrings
