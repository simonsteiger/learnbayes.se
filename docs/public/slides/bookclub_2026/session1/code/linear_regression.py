import pymc as pm

with pm.Model() as linear_regression:
    alpha = pm.Normal("alpha", mu=0, sigma=10)
    beta = pm.Normal("beta", mu=0, sigma=10)
    sigma = pm.Exponential("sigma", lam=1)
    pm.Normal("y", mu=alpha + beta * x, sigma=sigma, observed=y)
