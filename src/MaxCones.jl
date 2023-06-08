function neighbors_cones(v::NormalToricVariety)::Dict{Int64, Vector{Int64}}

    len = length(maximal_cones(v))

    ans = Dict{Int64, Vector{Int64}}([i for i in 1:len] .=> [Int64[] for _ in 1:len])

    for sigma1 in 1:(len-1)
        for sigma2 in (sigma1+1):len

            dim(intersect(maximal_cones(v)[sigma1], maximal_cones(v)[sigma2])) != (dim(v) - 1) && continue
            push!(ans[sigma1], sigma2)
            push!(ans[sigma2], sigma1)

        end
    end

    return ans
end

function is_admissible_color(nc::Dict{Int64, Vector{Int64}}, g::Graph{Undirected}, col::Tuple{Vararg{Int64}})::Bool

    return all(e -> col[src(e)] in nc[col[dst(e)]], edges(g))
end

function get_inv_curve(v::NormalToricVariety, nc::Dict{Int64, Vector{Int64}})::Dict{Tuple{Int64,Int64},CohomologyClass}
    
    ans = Dict{Tuple{Int64,Int64},CohomologyClass}() # the dict that will be returned
    if dim(v) == 1
        ans[(1,2)] = cohomology_class(v, gens(cohomology_ring(v))[1]^0)
        ans[(2,1)] = ans[(1,2)]
        return ans
    end
    n_colors = length(maximal_cones(v))

    for sigma1 in 1:n_colors
        for sigma2 in nc[sigma1]
            (sigma1, sigma2) in keys(ans) && continue
            
            cone_of_curve = intersect(maximal_cones(v)[sigma1], maximal_cones(v)[sigma2])

            index_of_cone_of_curve = index_in(cone_of_curve, cones(v,dim(v)-1))
            position = [0 for _ in 1:n_cones(v)]  # the position inside the list of all cones. It is an array of length equal to the number of cones, and the cones are listed by decresing dimension. 
            position[n_colors + index_of_cone_of_curve] = 1  # the positions relative to the maximal cones are 0, that of the intersected cone is 1

            ans[(sigma1, sigma2)] = cohomology_class( rational_equivalence_class(v, position) )
            ans[(sigma2, sigma1)] = ans[(sigma1, sigma2)]
        end
    end
    return ans
end

# function index_in(a::Union{Cone{QQFieldElem}, RayVector{QQFieldElem}}, b::SubObjectIterator{Cone{QQFieldElem}})::Int64
function index_in(a::Union{Cone{QQFieldElem}, RayVector{QQFieldElem}}, b::Union{SubObjectIterator{RayVector{QQFieldElem}},SubObjectIterator{Cone{QQFieldElem}}})::Int64
    ans = 0

    for i in b
        ans += 1
        a == i && break
    end

    return ans
end