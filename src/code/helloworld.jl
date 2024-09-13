using Turing, StatsFuns

N = 30
x = rand(Normal(0, 1), N)
p = [i > 1 ? 0.2 : 0.8 for i in x]
y = rand.(Bernoulli.(p))

@model function demo(x, y)
    α ~ Normal(0, 1)
    β ~ Normal(0, 1)

    for i in eachindex(y)
        p = logistic(α + β * x[i])
        y[i] ~ Bernoulli(p)
    end
end

model = demo(x, y)
chain = sample(model, NUTS(), MCMCThreads(), 1000, 4)
