module Turtle

export bags
export turtles

mutable struct bags
    vertexes::Union{Matrix{T} where T<:Real,Tuple}

    function bags(x::Union{Array{T} where T<:Real,Tuple} = vec([-35. -35. 35. 35.]), y::Union{Array{T} where T<:Real,Tuple} = vec([35. 0. 0. 35.]))
        if x isa Tuple
            x = collect(x)
        end

        if !(x isa Vector)
            # @warn "x is converted from $(typeof(x)) to Array{$(eltype(x)),1} by columns"
            x = vec(x)
        end

        if y isa Tuple
            y = collect(y)
        end

        if !(y isa Vector)
            # @warn "y is converted from $(typeof(y)) to Array{$(eltype(y)),1} by columns"
            y = vec(y)
        end

        if size(x) != size(y)
            DimensionMismatch("vector x,y dimensions mismatch")
        end

        new([x y])
    end
end

mutable struct pen
    color::Symbol
    size::Int
    up::Bool

    function pen(;color::Union{String,Symbol,AbstractFloat} = :blue, size = 5, up::Bool = true)
        new(color,size,up)
    end
end

mutable struct turtles
    bag::bags
    icon::String
    pos::Vector
    heading::AbstractFloat

    function turtles(;bag::bags = bags(), icon::String = "O", pos::Union{Array{T where T<:Real},Tuple} = vec([0.0,0.0]), heading::Real = 0.0)
        if pos isa Tuple
            pos = collect(pos)
        end

        if !(pos isa Vector)
            pos = vec(pos)
        end

        if length(pos) != 2
            DimensionMismatch("The new point to goto must have 2 elements [x,y]")
        end

        new(bag,icon,pos,heading)
    end
end

function goto(turtle::turtles,newpos::Array{T where T<:Real})
    if length(newpos) != 2
        DimensionMismatch("The new point to goto must have 2 elements [x,y]")
    end

    if !(newpos isa Vector)
        newpos = vec(newpos)
    end

    turtle.pos = newpos
end

function cw()
    body
end

end # module
