using Distributions

true_θ = 0.7
y = rand(Bernoulli(true_θ), 100)
