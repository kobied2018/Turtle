```@meta
EditURL = "<unknown>/src/DesitionTree.jl"
```

Needed packages

```@example DesitionTree
using DataFrames
```

this file holds the needed function to build a desition tree base on
[Iterative Dichotomiser 3 method](http://hunch.net/~coms-4771/quinlan.pdf)
this file documentation is base on [Weave.jl](https://github.com/JunoLab/Weave.jl) and [Literate](https://github.com/fredrikekre/Literate.jl)

# ENTROPY

this function calculate the entropy, at Base 2, of the input data for a given
category.

base 2 entropy is good for binary class that has only two values.
for more information see: [Entropy](https://en.wikipedia.org/wiki/Entropy)

```@example DesitionTree
function entropy2(data::DataFrame, categorycol::Symbol)
    #src # find the total number of samples
    totalnumofsamples = length(data[!,categorycol])
    #src # get the category sets (there should be only 2)
    categorysets = Set(data[!,categorycol])
    #src # define the Dictionary for the Probability of each dataset to have each categoryset
    Pcategory = Dict{String,Real}()
    for categoryset in categorysets
        #src # find the number of samples of the choosen dataset
        Pcategory[string(categoryset)] = count(i->i == categoryset, data[!,categorycol])/totalnumofsamples
    end
    return -sum([v == 0 ? 0 : v*log2(v) for v in values(Pcategory)])
end # function entropy2
```

# Best feature to split
this function run on all the features in the DataFrame and find the best
feature to split about, base on 'entropy2' function

```@example DesitionTree
function best_feature_to_split(data::DataFrame, features::Tuple, categorycol::Symbol)
    baseline = entropy2(data,categorycol) # the base line is the entropy of the total data
    feature_entropy =  Dict{String,Real}()
    #src # this for loop run on each feature column in the data and calculate his entropy
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
```

Potential leaf node
this function find the most common category

```@example DesitionTree
function potential_leaf_node(data::DataFrame, categorcol::Symbol)
    counter = Dict{String,Real}()
    categorysets = Set(data[!,categorycol])
    for categoryset in categorysets
        counter[string(categoryset)] = count(i->i == categoryset, data[!,categorcol])
    end

    return findmax(counter)
end # function potential_leaf_node
```

# Create Tree
the most common is define as the category which has larger percentage then the 'persent_threshold'
the default value is set to 100%

```@example DesitionTree
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
```

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

