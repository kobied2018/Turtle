using Turtle
import Turtle::bags
using Test
using Combinatorics

correct_bag_data_type = ([1 2 3],[1,2,3],[1;2;3],(1,2,3),
                         [1. 2. 3.],[1.,2.,3.],[1.;2.;3.],(1.,2.,3.))
correct_bag_test = combinations(correct_bag_data_type,2)
correct_bag_test_output = [[1.;2.;3.] [1.;2.;3.]]

non_correct_bag_data_type = ([1 2 3],[1 2 3 4],(1,2,3,4,5))
non_correct_bag_test = combinations(non_correct_bag_data_type,2)

@testset "Turtle.jl" begin
    @testset "create a correct bag" begin
        for datain in correct_bag_test
            @test begin
                mybag = bags(datain[1],datain[2])
                mybag.vertexes == correct_bag_test_output
            end
        end
    end

    @testset "create a non correct bag" begin
        for datain in non_correct_bag_test
            @test_throws DimensionMismatch bags(datain[1],datain[2])
        end
    end

end
