import ReferenceFrameRotations
using Makie
RF = ReferenceFrameRotations

mutable struct bags
    vertexes::Union{Matrix{T} where T<:Real,Tuple}

    function bags(x::Union{Array{T} where T<:Real,Tuple} = vec([-350. -350. 350. 350.]), y::Union{Array{T} where T<:Real,Tuple} = vec([350. -350. -350. 350.]))
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
    icon::Char
    pos::Vector
    heading::AbstractFloat
    main_scene::Scene
    plt::Dict{String,AbstractPlot}

    function turtles(;  bag::bags = bags(),
                        pen::pens = pens(),
                        icon::Char = '🐱',
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
        plt = Dict{String,AbstractPlot}()
        main_scene = Scene(resolution = (world_size[1],world_size[2]))
        plt["bag"] = lines!(main_scene,bag.vertexes[:,1],bag.vertexes[:,2])[end]
        plt["turtle_path"] = lines!(main_scene,[0,1],[0,1])[end]
        plt["turtle"] = scatter!(main_scene,[pos[1]],[pos[2]],marker = icon, markersize = 0.1*maximum(world_size))[end]
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
    R = RF.angle_to_dcm(turtle.heading,0,0)
    turtle.pos += vec(step * R[1,1:2])
end # function


"""
    turtle_plot(data)

this function plot datain with in the turtle.main_scene
"""
function turtle_plot(data)
    body
end # function







using Makie
import ReferenceFrameRotations
RF = ReferenceFrameRotations
plt = Dict{String,AbstractPlot}()
world_size = [1000,1000]
vertexes = [[-350;-350;350;350] [350;-350;-350;350]]
icon = '🐱'
heading = π/100
myconvert(d::ReferenceFrameRotations.Quaternion{T} where T) = Quaternionf0(d.q0,d.q1,d.q2,d.q3)
rot = myconvert(RF.angle_to_quat(heading,0,0))
pos = [0,0]
main_scene = Scene(resolution = (world_size[1],world_size[2]));
lines!(main_scene,vertexes[:,1],vertexes[:,2]);
plt["bag"] = main_scene[end];
lines!(main_scene,[0,1],[0,1]);
plt["turtle_path"] = main_scene[end];
scatter!(main_scene,[pos[1]],[pos[2]],marker = icon, markersize = 0.1*maximum(world_size), rotation = rot);
plt["turtle"] = main_scene[end];

plt["turtle"].marker = icon
plt["turtle"].rotation = normalize(rot)
