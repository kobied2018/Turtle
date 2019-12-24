import ReferenceFrameRotations
using Makie

mutable struct bags
    vertexes::Union{Matrix{T} where T<:Real,Tuple}

    function bags(x::Union{Array{T} where T<:Real,Tuple} = vec([-350. -350. 350. 350.]), y::Union{Array{T} where T<:Real,Tuple} = vec([350. 0. 0. 350.]))
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
    main_scene::Scene

    function turtles(;  bag::bags = bags(),
                        pen::pens = pens(),
                        icon::String = "O",
                        pos::Union{Tuple,Array{T} where T<:Real} = vec([0.0,0.0]),
                        heading::Real = 0.0,
                        world_size::Union{Tuple,Vector{T} where T<:Real} = vec([600., 600.]))

        if pos isa Tuple
            pos = collect(pos)
        end

        if !(pos isa Vector)
            pos = vec(pos)
        end

        if length(pos) != 2
            DimensionMismatch("The new point to goto must have 2 elements [x,y]")
        end

        if world_size isa Tuple
            world_size = vec(world_size)
        end

        if length(world_size) != 2
            DimensionMismatch("The worldSize must have 2 elements [width,hight]")
        end

        main_scene = Scene(resolution = (world_size[1],world_size[2]))
        lines!(main_scene,bag.vertexes[:,1],bag.vertexes[:,2])
        new(bag,pen,icon,pos,heading,main_scene);
    end
end

"""
     goto(turtle::turtles,newpos::Array{T} where T<:Real)

this function update the turtle position.
the input is a new point in [x,y] coords that the turtle jump to.
"""
function goto(turtle::turtles,newpos::Array{T}  where T<:Real)
    if length(newpos) != 2
        DimensionMismatch("The new point to goto must have 2 elements [x,y]")
    end

    if !(newpos isa Vector)
        newpos = vec(newpos)
    end

    turtle.pos = newpos
end
goto


"""
    cw(turtle::turtles,ang::Real)

this function update the turtle heading clock wise direction.
the input ang must be in [Rad], negative or positive angle
are treated as positive.
"""
function cw(turtle::turtles,ang::Real)
    turtle.heading -= abs(ang)
end # function cw


"""
    ccw(turtle::turtles,ang::Real)

this function update the turtle heading counter clock wise direction.
the input ang must be in [Rad], negative or positive angle
are treated as positive.
"""
function ccw(turtle::turtles,ang::Real)
    turtle.heading += abs(ang)
end # function


"""
    forward(turtle::turtles,step::AbstractFloat)

this function will advance the turtle forward in the heading direction
for distance of 'step'
"""
function forward(turtle::turtles,step::Real)
    R = ReferenceFrameRotations.angle_to_dcm(turtle.heading,0,0)
    turtle.pos += vec(step * R[1,1:2])
end # function

"""
    turtle_plot(data)

this function plot datain with in the turtle.main_scene
"""
function turtle_plot(data)
    body
end # function
