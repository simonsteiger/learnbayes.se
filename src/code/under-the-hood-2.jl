log_likelihood(θ, y) = sum(y) * log(θ) + sum(y .== 0) * log(1.0 - θ)
log_posterior(θ, y, prior) = log_likelihood(θ, y) + logpdf(prior, θ)
