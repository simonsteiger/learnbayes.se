import numpy as np
import pymc as pm
import arviz as az

N = 30
x = np.random.normal(0, 1, N)
p = np.where(x > 1, 0.2, 0.8)
y = np.random.binomial(1, p)

with pm.Model() as model:
    alpha = pm.Normal("alpha", mu=0, sigma=1)
    beta = pm.Normal("beta", mu=0, sigma=1)
    
    mu = alpha + beta * x
    
    p = pm.math.invlogit(mu)
    y_obs = pm.Bernoulli("y_obs", p=p, observed=y)
    
    idata = pm.sample(1000, tune=1000, chains=4, return_inferencedata=True)

summary = az.summary(idata)
