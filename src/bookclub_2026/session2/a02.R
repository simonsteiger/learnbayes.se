# Setup
n_sims <- 10000
n_posterior_draws <- 5

# Draw samples
p_samples <- rbeta(n_sims, 4, 12) # add 1 to alpha, beta
w_draws <- rbinom(n_sims, n_posterior_draws, p_samples)

# Show counts for each possible Binomial outcome
table(w_draws)

# Plot the table
plot(table(w_draws))
