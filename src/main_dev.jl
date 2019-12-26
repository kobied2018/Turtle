import ReferenceFrameRotations
using Plots
gr()

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

    function pens(;color::Union{String,Symbol,AbstractFloat} = :blue, size = 5, up::Bool = false)
        new(color,size,up)
    end
end

mutable struct turtles
    bag::bags
    pen::pens
    icon_shape::Symbol
    icon_size::Int
    pos::Vector
    heading::AbstractFloat
    plt::Plots.Plot
    history::Array{Any,2}

    function turtles(;  bag::bags = bags(),
                        pen::pens = pens(),
                        icon_shape::Symbol = :rect,
                        icon_size::Int = 5,
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
        plt = plot();
        plot!(plt,  bag.vertexes[:,1],bag.vertexes[:,2],
                    xlims = (-world_size[1],world_size[1]),
                    ylims = (-world_size[2],world_size[2]),
                    leg = false, xgrid = false, ygrid = false,
                    linewidth = pen.size, linecolor = pen.color);
        scatter!(plt,[pos[1]],[pos[2]],marker = (icon_shape,icon_size));
        plot!(plt,[pos[1]],[pos[2]]);
        history = [pos;false]'
        new(bag,pen,icon_shape,icon_size,pos,heading,plt,history);
    end
end


"""
    penup(turtle::turtles)

this function create a new searies data with in the main plot (turtle.plt)
and set turtle.pen_up = true
"""
function penup(turtle::turtles)
    turtle.pen.up = true
    turtle.history = [turtle.history;[NaN,NaN,NaN]']
    # plot!(turtle.plt,[turtle.pos[1]],[turtle.pos[2]]);
end # function penup


"""
    pendown(turtle::turtles)

this function set turtle.pen_up = false
and store position data
"""
function pendown(turtle::turtles)
    turtle.pen.up = false
    store_position_data(turtle)
end # function pendown


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
end #function goto



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
end # function ccw


"""
    forward(turtle::turtles,step::AbstractFloat)

this function will advance the turtle forward in the heading direction
for distance of 'step'
"""
function forward(turtle::turtles,step::Real)
    R = RF.angle_to_dcm(turtle.heading,0,0)
    turtle.pos += vec(step * R[1,1:2])
    if !turtle.pen.up
        store_position_data(turtle)
    end
end # function forward


"""
    turtle_plot(data)

this function plot datain with in the turtle.main_scene
"""
function turtle_plot(turtle::turtles)
    if !turtle.pen.up
        turtle.plt.series_list[end].plotattributes[:x] = turtle.history[:,1]
        turtle.plt.series_list[end].plotattributes[:y] = turtle.history[:,2]
        turtle.plt.series_list[2].plotattributes[:x] = turtle.pos[1]
        turtle.plt.series_list[2].plotattributes[:y] = turtle.pos[2]
        @show turtle.plt
    end
end # function turtle_plot


"""
    escaped(turtle::turtles)

this function check if the turtle escape the bag
"""
function escaped(turtle::turtles)
    res = false
    if  (turtle.pos[1] < minimum(turtle.bag.vertexes[:,1]) ||
        turtle.pos[1] > maximum(turtle.bag.vertexes[:,2])) ||
        (turtle.pos[2] < minimum(turtle.bag.vertexes[:,2]) ||
        turtle.pos[2] > maximum(turtle.bag.vertexes[:,2]))
        res = true
    end
    return res
end # function escaped


"""
    store_position_data(turtle::turtles)

this function save to last step the turtle did within an array
"""
function store_position_data(turtle::turtles)
    if !turtle.pen.up
        d = [turtle.pos;escaped(turtle)]'
        turtle.history = [turtle.history;d]
    end
end # function store_position_data


"""
    draw_line(turtle::turtles,turn_rad::Real, step::Real)

this function draw a line, by first rotating the turtle at 'turn_rad'
(ccw if 'turn_rad' > 0 and cw if 'turn_rad' < 0)
then move the turtle at the new direction distance of 'step'
"""
function draw_line(turtle::turtles,turn_rad::Real, step::Real)
    if turn_rad <= 0
        cw(turtle,turn_rad)
    else
        ccw(turtle,turn_rad)
    end
    forward(turtle,step)
    store_position_data(turtle)
end # function draw_line


"""
    draw_square(turtle::turtles, turn_rad::Real, step::Real)

this function draw a square rotated at 'turn_rad' and which rib size = 'step'
"""
function draw_square(turtle::turtles, turn_rad::Real, step::Real)
    draw_line(turtle,turn_rad,step)
    for ii in 1:3
        draw_line(turtle,π/2,step)
    end
end # function draw_square


"""
    draw_squares(turtle::turtles, N::Int, turn_rad::Real, step::Real, increase_step::Real)

this function draw 'N' squares,
the first square start at the curent turtle pos,
then it is rotated at initial 'turn_rad' radians,
with initial rib size = step.
the next square rib = 'step' + i*'increase_step'
"""
function draw_squares(  turtle::turtles,
                        N::Int = 1,
                        turn_rad::Real = 0,
                        step::Real = 50,
                        increase_step::Real = 50)
    draw_square(turtle, turn_rad, step)
    for ii in 1:N-1
        penup(turtle)
        forward(turtle,increase_step)
        cw(turtle,π/2)
        forward(turtle,increase_step)
        cw(turtle,π)
        pendown(turtle)
        draw_square(turtle, 0, step + ii*2*increase_step)
    end
end # function draw_squares


# ------------------------  Tests -------------------------------------------
function main_line()
    turtle = turtles()
    @show turtle.plt
    while !escaped(turtle)
        draw_line(turtle,0,500)
        turtle_plot(turtle)
    end
end # function


function main_square()
    turtle = turtles()
    @show turtle.plt
    while !escaped(turtle)
        draw_square(turtle,0,100)
        turtle_plot(turtle)
    end
end


function main_squares()
    turtle = turtles()
    @show turtle.plt
    while !escaped(turtle)
        draw_squares(turtle,5,0,100,100)
        turtle_plot(turtle)
    end
    return turtle.plt
end
