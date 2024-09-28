import numpy as np

def log_likelihood(theta, y):
    return np.sum(y) * np.log(theta) + np.sum(y == 0) * np.log(1.0 - theta)

def log_posterior(theta, y, prior):
    return log_likelihood(theta, y) + prior.logpdf(theta)
