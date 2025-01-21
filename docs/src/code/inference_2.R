log_likelihood <- function(theta, y) {
  sum(y) * log(theta) + sum(y == 0) * log(1 - theta)
}

log_posterior <- function(theta, y, alpha, beta) {
  log_likelihood(theta, y) + log(dbeta(theta, alpha, beta))
}