using Turing, LinearAlgebra

@model function random_intercept(group, y)
    n_groups = length(unique(group))
	
    ᾱ ~ Normal(0, 1)
    τ ~ Exponential(1)
    α ~ filldist(Normal(ᾱ, τ), n_groups)

    σ ~ Exponential(1)
	
    μ = α[group]
    y ~ MvNormal(μ, σ * I)
end

simulate(α, group; σ=1.0) = [rand(Normal(α[i], σ)) for i in group]

α = [-2, 0, 2]
group = repeat(1:3, 50)
y = vec(simulate(α, group))

m = random_intercept(group, y)
chn = sample(m, NUTS(), 1000)
