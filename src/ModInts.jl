module ModInts

import Base: +, -, *, /, <, one, zero, inv, abs
import Base: show, convert, getindex, promote_rule, Int

export ModInt

struct ModInt{n} <: Number
  val::Int
  ModInt{n}(val) where {n} = new(mod(val,n))
end

Int(a::ModInt{n}) where n = a.val

show(io::IO, a::ModInt{n}) where n = print(io, "$(a.val) mod $n")

inv(a::ModInt{n}) where n = invmod(a.val, n)

+(a::ModInt{n}, b::ModInt{n}) where n = ModInt{n}(a.val + b.val)
-(a::ModInt{n}) where n = ModInt{n}(n - a.val)
-(a::ModInt{n}, b::ModInt{n}) where n = ModInt{n}(a.val - b.val)
*(a::ModInt{n}, b::ModInt{n}) where n = ModInt{n}(a.val * b.val)
/(a::ModInt{n}, b::ModInt{n}) where n = a * inv(b)

<(a::ModInt{n}, b::ModInt{n}) where n = a.val < b.val

one(a::ModInt{n})  where n = ModInt{n}(1)
zero(a::ModInt{n}) where n = ModInt{n}(0)

# Lee norm on Z_n
abs(a::ModInt{n}) where n = a.val <= n/2 ? convert(Int, a) : convert(Int, -a)

convert(::Type{ModInt{n}}, x::Integer) where n = ModInt{n}(x)
convert(::Type{T}, x::ModInt{n}) where {n, T<:Integer} = convert(T, x.val)

getindex(t::Union{Tuple,Vector}, i::ModInt{n})   where n = getindex(t, i.val + 1)

promote_rule(::Type{ModInt{n}}, ::Type{<:Integer}) where n = ModInt{n}

end # module