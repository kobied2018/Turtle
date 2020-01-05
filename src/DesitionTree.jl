using DataFrames

"""
    ID3(data,feature,tree::Dict)

this function build a desition tree base on 'Iterative Dichotomiser 3 method'
http://hunch.net/~coms-4771/quinlan.pdf
"""


# """
#     entropy2(data::DataFrame, feature_col::Symbol, categorcol::Symbol)
#
# this function calculate the data entropy using base 2.
# this is good for binary class that can have only two values.
# the function output the current tested feature gain
# """
# function entropy2(data::DataFrame, feature_col::Symbol, categorcol::Symbol)
#     H = Dict{String,Real}() # define the Dictionary for the dataset split entropy
#     totalnumofsamples = length(data[!,categorcol]) # find the total number of samples
#     categorysets = Set(data[!,categorcol]) # get the category sets (there should be only 2)
#     # baseline entropy across all your data without a split
#     Pdata = Dict{String,Real}()
#     Hdata = Dict{String,Real}()
#     for categoryset in categorysets
#         Pdata[string(categoryset)] = count(i->i == categoryset, data[!,categorcol])/totalnumofsamples
#     end
#     H["data"] = -sum([v == 0 ? 0 : v*log2(v) for v in values(Pdata)])
#
#
#     datasets = Set(data[!,feature_col]) # get the tested variable sets
#     Pdataset = Dict{String,Dict{String,Real}}() # define the Dictionary for the Probability of each dataset to have each categoryset
#     numofsamples = Dict{String,Real}()
#     # calculate for each variable set the probability of each category set
#     for dataset in datasets
#         categorydata = data[data[:,feature_col] .== dataset,categorcol] # take the category data corresponding to the choosen dataset
#         numofsamples[string(dataset)] = count(i->i == dataset, data[!,feature_col]) # find the number of samples of the choosen dataset
#         for categoryset in categorysets
#             if haskey(Pcategory,string(dataset))
#                 merge!(Pcategory[string(dataset)], Dict(string(categoryset) =>  sum([d == categoryset for d in categorydata])/numofsamples[string(dataset)]))
#             else
#                 Pcategory[string(dataset)] = Dict(string(categoryset) => sum([d == categoryset for d in categorydata])/numofsamples[string(dataset)])
#             end
#         end
#     end
#
#     Pvar = Dict{String,Real}() # define the Dictionary for the Probability for each dataset from the total data
#     for dataset in datasets
#         Pvar[string(dataset)] = numofsamples[string(dataset)]/totalnumofsamples
#         H[string(dataset)] = -sum([v == 0 ? 0 : v*log2(v) for v in values(Pcategory[string(dataset)])])
#     end
#
#     H["split"] = sum([p*h for (p,h) in zip(values(Pvar),values(H))])
#
#
#     gain = H["data"] - H["split"]
#     @show H
#     return gain
# end # function entropy2


"""
    entropy2(data::DataFrame, categorycol::Symbol)

this function calculate the class entropy using base 2.
this is good for binary class that can have only two values.
the function output the class entropy
"""
function entropy2(data::DataFrame, categorycol::Symbol)
    totalnumofsamples = length(data[!,categorycol]) # find the total number of samples
    categorysets = Set(data[!,categorycol]) # get the category sets (there should be only 2)
    Pcategory = Dict{String,Real}() # define the Dictionary for the Probability of each dataset to have each categoryset
    for categoryset in categorysets
        Pcategory[string(categoryset)] = count(i->i == categoryset, data[!,categorycol])/totalnumofsamples # find the number of samples of the choosen dataset
    end
    return -sum([v == 0 ? 0 : v*log2(v) for v in values(Pcategory)])
end # function entropy2


"""
    best_feature_to_split(data::DataFrame, features::Tuple{Symbol}, categorcol::Symbol)

this function run on all the features in the DataFrame and find the best
feature to split about, base on 'entropy2' function
"""
function best_feature_to_split(data::DataFrame, features::Tuple, categorycol::Symbol)
    baseline = entropy2(data,categorycol)
    feature_entropy =  Dict{String,Real}()
    for feature in features
        feature_entropy[string(feature)] = 0.0
        categorysets = Set(data[!,categorycol])
        for categoryset in categorysets
            partitioned_data = filter(row -> row[categorycol] == categoryset,data)
            porportion = length(partitioned_data[!,feature])/length(data[!,feature])
            feature_entropy[string(feature)] += porportion * entropy2(partitioned_data, feature)
        end
    end
    information_gain = Dict{String,Real}()
    for feature in features
        information_gain[string(feature)] = baseline - feature_entropy[string(feature)]
    end
    return findmax(information_gain)
end # function best_feature_to_split

"""
    potential_leaf_node(data::DataFrame, categorcol::Symbol)

this function find the most common category,
"""
function potential_leaf_node(data::DataFrame, categorcol::Symbol)
    counter = Dict{String,Real}()
    categorysets = Set(data[!,categorycol])
    for categoryset in categorysets
        counter[string(categoryset)] = count(i->i == categoryset, data[!,categorcol])
    end

    return findmax(counter)
end # function potential_leaf_node


"""
    create_tree(data::DataFrame, features::Tuple, categirycol::Symbol, persent_threshold::Int = 100)

the most common is define as the category which has larger percentage then the 'persent_threshold'
the default value is set to 100%
"""
function create_tree(data::DataFrame, features::Tuple, categorycol::Symbol, persent_threshold::Int = 100)
    counter , category = potential_leaf_node(data, categorycol)
    counter == length(data[!,categorycol]) && return category
    node = Dict{String,Dict}()
    feature_gain, feature_lable = best_feature_to_split(data, features, categorycol)
    node[feature_lable] = Dict()
    classes = Set(data[!,Symbol(feature_lable)])
    for c in classes
        partitioned_data = data[data[!,Symbol(feature_lable)] .== c,:]
        node[feature_lable][string(c)] = create_tree(partitioned_data, features, categorycol)
    end
    return node
end # function create_tree


"""
    classify(tree::Dict, data)

this function classify data using the a tree
"""
function classify(args)
    body
end # function
