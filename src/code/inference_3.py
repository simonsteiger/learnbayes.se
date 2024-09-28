import numpy as np
from scipy import stats

def calculate_accept_prob(theta_proposed, theta_current, y, prior):
    log_proposed = log_posterior(theta_proposed, y, prior)
    log_current = log_posterior(theta_current, y, prior)
    return np.exp(log_proposed - log_current)

def metropolis_hastings(y, prior, n_iterations):
    theta_current = prior.rvs()
    samples = np.zeros(n_iterations)
    
    for i in range(n_iterations):
        theta_proposed = stats.beta(theta_current * 10, (1 - theta_current) * 10).rvs()
        
        accept_prob = calculate_accept_prob(theta_proposed, theta_current, y, prior)
        
        if np.random.random() < accept_prob:
            theta_current = theta_proposed
        
        samples[i] = theta_current
    
    return samples

n_iterations = 10_000
samples = metropolis_hastings(y, prior, n_iterations)
