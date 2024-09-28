calculate_accept_prob <- function(theta_proposed, theta_current, y, prior) {
  log_proposed <- log_posterior(theta_proposed, y, prior)
  log_current <- log_posterior(theta_current, y, prior)
  exp(log_proposed - log_current)
}

metropolis_hastings <- function(data, alpha, beta, n_iterations) {
  theta_current <- rbeta(1, alpha, beta)
  samples <- numeric(n_iterations)

  for (i in seq_len(n_iterations)) {
    theta_proposed <- rbeta(1, theta_current * 10, (1 - theta_current) * 10)

    accept_prob <- calculate_accept_prob(theta_proposed, theta_current, y, prior)

    if (runif(1) < accept_prob) {
      theta_current <- theta_proposed
    }

    samples[i] <- theta_current
  }

  return(samples)
}

n_iteratios <- 10000
samples <- metropolis_hastings(y, alpha, beta, n_iterations)