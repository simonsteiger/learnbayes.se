library(rethinking)

linear_regression <- ulam(
  alist(
    y ~ dnorm(mu, sigma),
    mu <- alpha + beta * x,
    alpha ~ dnorm(0, 10),
    beta ~ dnorm(0, 10),
    sigma ~ dexp(1)
  ),
  data = list(x = x, y = y)
)
