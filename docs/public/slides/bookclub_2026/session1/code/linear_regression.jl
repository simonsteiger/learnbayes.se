using Turing

@model function linear_regression(x, y)
    α ~ Normal(0, 10)
    β ~ Normal(0, 10)
    σ ~ Exponential(1)
    for i in eachindex(x, y)
        y[i] ~ Normal(α + β * x[i], σ)
    end
end
