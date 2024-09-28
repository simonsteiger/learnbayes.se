function calculate_accept_prob(θ_proposed, θ_current, y, prior)
    log_proposed = log_posterior(θ_proposed, y, prior)
    log_current = log_posterior(θ_current, y, prior)
    return exp(log_proposed - log_current)
end

function metropolis_hastings(y, prior, n_iterations)
    θ_current = rand(prior)
    samples = zeros(n_iterations)
    
    for i in 1:n_iterations
        θ_proposed = rand(Beta(θ_current * 10, (1 - θ_current) * 10))
        
        accept_prob = calculate_accept_prob(θ_proposed, θ_current, y, prior)
        
        if rand() < accept_prob
            θ_current = θ_proposed
        end
        
        samples[i] = θ_current
    end
    
    return samples
end

n_iterations = 10_000
samples = metropolis_hastings(y, prior, n_iterations)
