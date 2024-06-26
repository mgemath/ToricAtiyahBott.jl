export
    moment_graph

function neighbors_cones(v::NormalToricVariety)::Dict{Int64,Vector{Int64}}

    len = length(maximal_cones(v))

    ans = Dict{Int64,Vector{Int64}}([i for i in 1:len] .=> [Int64[] for _ in 1:len])

    for sigma1 in 1:(len-1)
        for sigma2 in (sigma1+1):len
            count(x -> x in rays(maximal_cones(v)[sigma1]), rays(maximal_cones(v)[sigma2])) != (dim(v) - 1) && continue
            push!(ans[sigma1], sigma2)
            push!(ans[sigma2], sigma1)

        end
    end

    #order the elements
    foreach(sigma1 -> sort!(ans[sigma1]), 1:len)
    
    return ans
end

function get_inv_curve(v::NormalToricVariety, nc::Dict{Int64,Vector{Int64}})::Dict{Tuple{Int64,Int64},CohomologyClass}

    ans = Dict{Tuple{Int64,Int64},CohomologyClass}() # the dict that will be returned
    if dim(v) == 1
        ans[(1, 2)] = cohomology_class(v, gens(cohomology_ring(v))[1]^0)
        ans[(2, 1)] = ans[(1, 2)]
        return ans
    end
    n_colors = length(maximal_cones(v))

    for sigma1 in 1:n_colors
        for sigma2 in nc[sigma1]
            (sigma1, sigma2) in keys(ans) && continue

            # cone_of_curve = intersect(maximal_cones(v)[sigma1], maximal_cones(v)[sigma2])
            cone_of_curve = positive_hull(filter(x -> x in rays(maximal_cones(v)[sigma1]), rays(maximal_cones(v)[sigma2])))

            index_of_cone_of_curve = findfirst(j -> j == cone_of_curve, cones(v, dim(v) - 1))
            position = [0 for _ in 1:n_cones(v)]  # the position inside the list of all cones. It is an array of length equal to the number of cones, and the cones are listed by decresing dimension. 
            position[n_colors+index_of_cone_of_curve] = 1  # the positions relative to the maximal cones are 0, that of the intersected cone is 1

            ans[(sigma1, sigma2)] = cohomology_class(rational_equivalence_class(v, position))
            ans[(sigma2, sigma1)] = ans[(sigma1, sigma2)]
        end
    end
    return ans
end


"""
    moment_graph(v; show_graph)

The moment graph of the toric variety ``v``. It prints all pairs ``(i,j)``, together with the cohomology class of the invariant curve passing through the points corresponding to the maximal cones ``i`` and ``j``. The cohomology class is expressed in the coordinates of the Chow ring. 
# Arguments
- `v::NormalToricVariety`: the toric variety.

# Example
```jldoctest; setup = :(using Oscar, ToricAtiyahBott)
julia> P2 = projective_space(NormalToricVariety, 2);

julia> mg = moment_graph(P2);
(1,2) -> x3
(1,3) -> x3
(2,3) -> x3

julia> C = mg[1,2];
```
If `show_graph` is omitted or false, the output is omitted.
```jldoctest; setup = :(using Oscar, ToricAtiyahBott)
julia> P1 = projective_space(NormalToricVariety, 1);

julia> mg = moment_graph(P1, show_graph=false);
```
"""
function moment_graph(v::NormalToricVariety; show_graph::Bool=true)::Dict{Tuple{Int64,Int64},CohomologyClass}

    nc = neighbors_cones(v)
    ans = get_inv_curve(v, nc)

    if show_graph
        for i in 1:n_maximal_cones(v)
            for j in (i+1):n_maximal_cones(v)
                i in nc[j] || continue
                println("($i,$j) -> ", polynomial(ans[i, j]))
            end
        end
    end

    return ans
end