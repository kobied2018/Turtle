module Turtle

import ReferenceFrameRotations
# include(raw"D:\gitRepository\my_proj\Genetic Algorithms and Machine learning\Turtle\src\LSystem.jl")
using Plots
using CSV, DataFrames
gr()

RF = ReferenceFrameRotations

#===================== Export Struct & Constructores =======================#
export Bags, Pens, Turtles

#============================ Export Functions =============================#
export main_proj

mutable struct DeafultVals
    turn_rad::Real
    step::Real
    do_till_escaped::Bool
    N::Int
    increase_step::Real
    ang::Real

    function DeafultVals()
        turn_rad = 0
        step = 100
        do_till_escaped = false
        N = 10
        increase_step = 50
        ang = deg2rad(120)
        new(turn_rad,step,do_till_escaped,N,increase_step,ang)
    end
end


mutable struct Bags
    vertexes::Union{Matrix{T} where T<:Real,Tuple}

    function Bags(x::Union{Array{T} where T<:Real,Tuple} = vec([-350. -350. 350. 350.]), y::Union{Array{T} where T<:Real,Tuple} = vec([350. -350. -350. 350.]))
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


mutable struct Pens
    color::Symbol
    size::Int
    up::Bool

    function Pens(;color::Union{String,Symbol,AbstractFloat} = :blue, size = 5, up::Bool = false)
        new(color,size,up)
    end
end

mutable struct Turtles
    bag::Bags
    pen::Pens
    icon_shape::Symbol
    icon_size::Int
    pos::Vector
    heading::AbstractFloat
    plt::Plots.Plot
    history::Array{Any,2}

    function Turtles(;  bag::Bags = Bags(),
                        pen::Pens = Pens(),
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


#========================= Function =======================================#

"""
    penup(turtle::Turtles)

this function create a new searies data with in the main plot (turtle.plt)
and set turtle.pen_up = true
"""
function penup(turtle::Turtles)
    turtle.pen.up = true
    turtle.history = [turtle.history;[NaN,NaN,NaN]']
    # plot!(turtle.plt,[turtle.pos[1]],[turtle.pos[2]]);
end # function penup


"""
    pendown(turtle::Turtles)

this function set turtle.pen_up = false
and store position data
"""
function pendown(turtle::Turtles)
    turtle.pen.up = false
    store_position_data(turtle)
end # function pendown


"""
     goto(turtle::Turtles,newpos::Array{T} where T<:Real)

this function update the turtle position.
the input is a new point in [x,y] coords that the turtle jump to.
"""
function goto(turtle::Turtles,newpos::Array{T}  where T<:Real)
    if length(newpos) != 2
        DimensionMismatch("The new point to goto must have 2 elements [x,y]")
    end

    if !(newpos isa Vector)
        newpos = vec(newpos)
    end

    turtle.pos = newpos
end #function goto



"""
    cw(turtle::Turtles,ang::Real)

this function update the turtle heading clock wise direction.
the input ang must be in [Rad], negative or positive angle
are treated as positive.
"""
function cw(turtle::Turtles,ang::Real)
    turtle.heading -= abs(ang)
end # function cw


"""
    ccw(turtle::Turtles,ang::Real)

this function update the turtle heading counter clock wise direction.
the input ang must be in [Rad], negative or positive angle
are treated as positive.
"""
function ccw(turtle::Turtles,ang::Real)
    turtle.heading += abs(ang)
end # function ccw


"""
    forward(turtle::Turtles,step::AbstractFloat)

this function will advance the turtle forward in the heading direction
for distance of 'step'
"""
function forward(turtle::Turtles,step::Real)
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
function turtle_plot(turtle::Turtles)
    if !turtle.pen.up
        turtle.plt.series_list[end].plotattributes[:x] = turtle.history[:,1]
        turtle.plt.series_list[end].plotattributes[:y] = turtle.history[:,2]
        turtle.plt.series_list[2].plotattributes[:x] = turtle.pos[1]
        turtle.plt.series_list[2].plotattributes[:y] = turtle.pos[2]
    end
end # function turtle_plot


"""
    escaped(turtle::Turtles)

this function check if the turtle escape the bag
"""
function escaped(turtle::Turtles)
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
    store_position_data(turtle::Turtles)

this function save to last step the turtle did within an array
"""
function store_position_data(turtle::Turtles)
    if !turtle.pen.up
        d = [turtle.pos;escaped(turtle)]'
        turtle.history = [turtle.history;d]
    end
end # function store_position_data


"""
    draw_line(turtle::Turtles,turn_rad::Real, step::Real)

this function draw a line, by first rotating the turtle at 'turn_rad'
(ccw if 'turn_rad' > 0 and cw if 'turn_rad' < 0)
then move the turtle at the new direction distance of 'step'
the function check if the turtle escaped the bag and return true or false
"""
function draw_line( turtle::Turtles,
                    turn_rad::Real = 0,
                    step::Real = 100)
    if turn_rad <= 0
        cw(turtle,turn_rad)
    else
        ccw(turtle,turn_rad)
    end
    forward(turtle,step)
    store_position_data(turtle)
    return escaped(turtle)
end # function draw_line


"""
    draw_square(turtle::Turtles, turn_rad::Real, step::Real, do_till_escaped::Bool)

this function draw a square rotated at 'turn_rad' and which rib size = 'step'
if 'do_till_escaped' == true, the function will stop when turtle escaped
"""
function draw_square(   turtle::Turtles,
                        turn_rad::Real,
                        step::Real,
                        do_till_escaped::Bool)
    res = false
    escaped = draw_line(turtle,turn_rad,step)
    if do_till_escaped && escaped
        res = true
    else
        for ii in 1:3
            escaped = draw_line(turtle,π/2,step)
            if do_till_escaped && escaped
                res = true
                break
            end
        end
    end
    return res
end # function draw_square


"""
    draw_squares(turtle::Turtles, N::Int, turn_rad::Real, step::Real, increase_step::Real, do_till_escaped::Bool)

this function draw 'N' squares,
the first square start at the curent turtle pos,
then it is rotated at initial 'turn_rad' radians,
with initial rib size = step.
the next square rib = 'step' + i*'increase_step'
if 'do_till_escaped' == true, the function will stop when turtle escaped
"""
function draw_squares(  turtle::Turtles,
                        N::Int,
                        turn_rad::Real,
                        step::Real,
                        increase_step::Real,
                        do_till_escaped::Bool)
    res = false
    escaped = draw_square(turtle, turn_rad, step, do_till_escaped)
    if do_till_escaped && escaped
        res = true
    else
        for ii in 1:N-1
            penup(turtle)
            forward(turtle,increase_step)
            cw(turtle,π/2)
            forward(turtle,increase_step)
            cw(turtle,π)
            pendown(turtle)
            escaped = draw_square(turtle, 0, step + ii*2*increase_step, do_till_escaped)
            if do_till_escaped && escaped
                res = true
                break
            end
        end
    end
    return res
end # function draw_squares


"""
    draw_triangles(turtle::Turtles, turn_rad::Real, N::Int, ang::Real, step::Real, increase_step::Real, do_till_escaped::Bool)

this function draw spriangles with angle = 'ang'
and initial rib size = 'step'
and rib = step + i * increase_step
if 'do_till_escaped' == true, the function will stop when turtle escaped
"""
function draw_triangles(turtle::Turtles,
                        turn_rad::Real,
                        N::Int,
                        ang::Real,
                        step::Real,
                        increase_step::Real,
                        do_till_escaped::Bool)
    res = false
    escaped = draw_line(turtle,turn_rad,step)
    if do_till_escaped && escaped
        res = true
    else
        for ii in 1:3*N-1
            escaped = draw_line(turtle,ang,step + ii*increase_step)
            if do_till_escaped && escaped
                res = true
                break
            end
        end
    end
    return res
end # function draw_triangles


"""
    save_to_file(turtle::Turtles)

this function save the turtle.history data to csv file
after filterring NaN values
"""
function save_to_file(turtle::Turtles,csvFilenameIn::String = "run_1.csv")
    if occursin(r".csv",csvFilenameIn)
        splitName = split(fullFileName,'.')
        endSplitName = splitName[1][end]
        if isnumeric(endSplitName)
            fullFileName = csvFilenameIn
        else
            fullFileName = splitName[1] * "_1.csv"
        end
    else
        if isnumeric(csvFilenameIn[end])
            fullFileName = csvFilenameIn * ".csv"
        else
            fullFileName = csvFilenameIn * "_1.csv"
        end
    end

    while isfile(fullFileName)
        splitName = split(fullFileName,'.')
        endSplitName = splitName[1][end]
        if isnumeric(endSplitName)
            numlength = sum(map(isnumeric,collect(splitName[1])))
            fileNameApendix = string(parse(Int64,splitName[1][end - numlength + 1 : end]) + 1)
        else
            fileNameApendix = "1"
        end

        fullFileName = splitName[1][1:end - length(fileNameApendix)] * fileNameApendix * ".csv"
    end

    datatofile = DataFrame(turtle.history)
    filter!(row->!isnan(row.x1),datatofile)
    CSV.write(fullFileName,  datatofile, writeheader=false)
end # function save_to_file


"""
    input(prompt::String = "", df_val::DeafultVals)::String

this function ask the user to enter needed params for the called function
"""
function popup_my_input(df_val, prompt::String = "")
    println(prompt)
    str = chomp(readline())
    if isempty(str)
        val = df_val
    else
        val = parse(typeof(df_val),str)
    end
    return val
end # function input


"""
    get_inputs_list(f::Function)

this function extract the given function, it's input argumant list
"""
function get_inputs_list(f::Function)
    list = []
    for m in methods(f)
        push!(list,m.slot_syms)
    end
    inputlist = Dict{String,Symbol}()
    for str in list
        splitlist = split(str,"\0")
        for s in splitlist
            if s == "#self#" || s == ""
                continue
            end
            if !haskey(inputlist,s)
                inputlist[s] = Symbol(s)
            end
        end
    end
    return inputlist
end # function get_inputs_list


"""
    get_my_input(dv::DeafultVals, ex)

this function call the function 'popup_my_input', to ask for the user to enter
the needed value for the needed var
"""
function get_my_input(dv::DeafultVals, ex)
    println("give value to $(string(ex)) or press ENTER for deafult")
    if ex == :turn_rad
        dv.turn_rad = popup_my_input(dv.turn_rad, "enter angle, in Rad, to rotate the turtle (positive -> ccw, negative -> cw), deafult = $(dv.turn_rad)")
        println("value entered = $(dv.turn_rad)")
    end
    if ex == :step
        dv.step = popup_my_input(dv.step, "enter step size, deafult = $(dv.step)")
        println("value entered = $(dv.step)")
    end
    if ex == :N
        dv.N = popup_my_input(dv.N, "enter number of reapets, deafult = $(dv.N)")
        println("value entered = $(dv.N)")
    end
    if ex == :ang
        dv.ang = popup_my_input(dv.ang, "enter triangle angle, in Rad, deafult = $(dv.ang)")
        println("value entered = $(dv.ang)")
    end
    if ex == :increase_step
        dv.increase_step = popup_my_input(dv.increase_step, "enter step increase size, deafult = $(dv.increase_step)")
        println("value entered = $(dv.increase_step)")
    end
    if ex == :do_till_escaped
        dv.do_till_escaped = popup_my_input(dv.do_till_escaped, "enter do_till_escaped, deafult = $(dv.do_till_escaped)")
        println("value entered = $(dv.do_till_escaped)")
    end
    println("===============================================================")
    println("")
end # function my_input


#================================= MACROS ===================================#
# see : https://discourse.julialang.org/t/undefvarerror-x-not-defined-when-calling-a-macro-outside-of-its-module/20201/3
# for explanation on the use of 'esc' in macro
macro run_type(type,func_type_dict,turtle,dv)
    quote
        local _type = $(esc(type))
        local _func_type_dict = $(esc(func_type_dict))
        local _turtle = $(esc(turtle))
        local _dv = $(esc(dv))
        inputs_needed = get_inputs_list(_func_type_dict[_type][1])
        for (k,v) in inputs_needed
            if v == :turtle
                continue
            end
            get_my_input(_dv,v)
        end
        if _dv.do_till_escaped
            _func_type_dict[_type][3](_turtle,_dv)
        else
            _func_type_dict[_type][2](_turtle,_dv)
        end
    end
end # macro run_type

# ------------------------  Tests -------------------------------------------
function main_line(turtle::Turtles, dv::DeafultVals)
    # turtle = Turtles()
    draw_line(turtle,dv.turn_rad,dv.step)
    turtle_plot(turtle)
    save_to_file(turtle,"main_line")
    return turtle.plt
end


function main_line_till_escaped(turtle::Turtles, dv::DeafultVals)
    # turtle = Turtles()
    escaped = false
    while !escaped
        escaped = draw_line(turtle,dv.turn_rad,dv.step)
        turtle_plot(turtle)
    end
    save_to_file(turtle,"main_line_till_escaped")
    return turtle.plt
end


function main_squares(turtle::Turtles, dv::DeafultVals)
    # turtle = Turtles()
    draw_squares(turtle,dv.N,dv.turn_rad,dv.step,dv.increase_step,dv.do_till_escaped)
    turtle_plot(turtle)
    save_to_file(turtle,"main_squares")
    return turtle.plt
end


function main_squares_till_escaped(turtle::Turtles, dv::DeafultVals)
    # turtle = Turtles()
    escaped = false
    while !escaped
        escaped = draw_squares(turtle,dv.N,dv.turn_rad,dv.step,dv.increase_step,dv.do_till_escaped)
        turtle_plot(turtle)
    end
    save_to_file(turtle,"main_squares_till_escaped")
    return turtle.plt
end


function main_triangles(turtle::Turtles, dv::DeafultVals)
    # turtle = Turtles()
    draw_triangles(turtle, dv.turn_rad, dv.N, dv.ang, dv.step, dv.increase_step, dv.do_till_escaped)
    turtle_plot(turtle)
    save_to_file(turtle,"main_triangles")
    return turtle.plt
end

function main_triangles_till_escaped(turtle::Turtles, dv::DeafultVals)
    # turtle = Turtles()
    escaped = false
    while !escaped
        escaped = draw_triangles(turtle, dv.turn_rad, dv.N, dv.ang, dv.step, dv.increase_step, dv.do_till_escaped)
        turtle_plot(turtle)
    end
    save_to_file(turtle,"main_triangles_till_escaped")
    return turtle.plt
end


"""
    main_porj(moveType::String, stop_condition::String; N::Int, trun_rad::Real)

documentation
"""
function main_proj(move_type_in::String)
    turtle = Turtles()
    dv = DeafultVals()
    func_type_dict = Dict(  :line => [draw_line, main_line, main_line_till_escaped],
                            :squares => [draw_squares, main_squares, main_squares_till_escaped],
                            :triangles => [draw_triangles, main_triangles, main_triangles_till_escaped])
    move_type = Symbol(move_type_in)
    @run_type(move_type,func_type_dict,turtle,dv)
    # @macroexpand @run_type(Symbol(moveType), func_type_dict, turtle, dv)
end # function main_proj
end #module
