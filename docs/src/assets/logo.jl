using CairoMakie

using Distributions

using Random

using Colors

using LaTeXStrings

plum, orange, grey = colorant"#870052", colorant"#FF876F", colorant"#666666"

p = 0.6

rng = Xoshiro(200)
x = rand(rng, Bernoulli(p), 24)

α, β = 2, 7

n_samples = Int(3e7)

prior = Beta(α, β)

prior_samples = rand(prior, n_samples)

likelihood_samples = rand(Beta(1 + sum(x), 1 + sum(x .== 0)), n_samples)

keep_idx = [3, 10, 24]

posterior_samples = []

for i in eachindex(x)
    i in keep_idx || continue
    v = collect(Iterators.take(x, i))
    push!(posterior_samples, rand(Beta(α + sum(v), β + sum(v .== 0)), n_samples))
end

max_alpha_fill = 0.8
max_alpha_stroke = 1.0
max_strokewidth = 1.8

fig = Figure(backgroundcolor=:transparent)

colsize!(fig.layout, 1, Aspect(1, 1.0))
resize_to_layout!(fig)

ax = Axis(
    fig[1, 1],
    backgroundcolor=:transparent,
    spinewidth=2.0,
    limits=(nothing, (0, nothing)),
)
density!(
    prior_samples,
    color=grey,
    strokewidth=max_strokewidth,
    strokecolor=(:black, max_alpha_stroke)
)

density!(
    likelihood_samples,
    color=(plum, max_alpha_fill),
    strokewidth=max_strokewidth,
    strokecolor=(colorant"#4F0433", max_alpha_stroke)
)

opacity_triplet(x) = [x / 4, x / 2, x]
alphas_fill = opacity_triplet(max_alpha_fill)
alphas_stroke = opacity_triplet(max_alpha_stroke)
strokewidth = opacity_triplet(max_strokewidth)

for i in eachindex(keep_idx)
    density!(
        posterior_samples[i],
        color=(orange, alphas_fill[i]),
        strokewidth=strokewidth[i],
        strokecolor=(colorant"#FF5E3D", alphas_stroke[i])
    )
end

hidedecorations!(ax)
hidespines!(ax, :l, :r, :t)

save(joinpath(@__DIR__, "updating_simple.svg"), fig)

text!(0.0, 3.8, text=L"\pi(\theta | y) \propto \pi(y | \theta) \pi(\theta)", color=colorant"#111828", fontsize=22)

save(joinpath(@__DIR__, "updating.svg"), fig)
