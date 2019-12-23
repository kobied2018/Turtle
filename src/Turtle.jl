module Turtle

import ReferenceFrameRotations
using Makie

# export bags
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

mutable struct pens
    color::Symbol
    size::Int
    up::Bool

    function pens(;color::Union{String,Symbol,AbstractFloat} = :blue, size = 5, up::Bool = true)
        new(color,size,up)
    end
end

mutable struct turtles
    bag::bags
    pen::pens
    icon::String
    pos::Vector
    heading::AbstractFloat
    worldSize::Vector

    function turtles(;pen::pens = pens(), bag::bags = bags(), icon::String = "O", pos::Union{Array{T where T<:Real},Tuple} = vec([0.0,0.0]), heading::Real = 0.0)
        if pos isa Tuple
            pos = collect(pos)
        end

        if !(pos isa Vector)
            pos = vec(pos)
        end

        if length(pos) != 2
            DimensionMismatch("The new point to goto must have 2 elements [x,y]")
        end

        new(pen,bag,icon,pos,heading)
    end
end


"""
     goto(turtle::turtles,newpos::Array{T where T<:Real})

this function update the turtle position.
the input is a new point in [x,y] coords that the turtle jump to.
"""
function goto(turtle::turtles,newpos::Array{T where T<:Real})
    if length(newpos) != 2
        DimensionMismatch("The new point to goto must have 2 elements [x,y]")
    end

    if !(newpos isa Vector)
        newpos = vec(newpos)
    end

    turtle.pos = newpos
end


"""
    cw(turtle::turtles,ang::AbstractFloat)

this function update the turtle heading clock wise direction.
the input ang must be in [Rad], negative or positive angle
are treated as positive.
"""
function cw(turtle::turtles,ang::AbstractFloat)
    turtle.heading -= abs(ang)
end # function cw


"""
    ccw(turtle::turtles,ang::AbstractFloat)

this function update the turtle heading counter clock wise direction.
the input ang must be in [Rad], negative or positive angle
are treated as positive.
"""
function ccw(turtle::turtles,ang::AbstractFloat)
    turtle.heading += abs(ang)
end # function


"""
    forward(turtle::turtles,step::AbstractFloat)

this function will advance the turtle forward in the heading direction
for distance of 'step'
"""
function forward(turtle::turtles,step::AbstractFloat)
    R = ReferenceFrameRotations.angle_to_dcm(turtle.heading,0,0)
    turtle.pos += vec(step * R[1,1:2])
end # function

end # module
