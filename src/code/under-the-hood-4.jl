using StatsPlots

histogram(samples, normalize=:pdf, label="Posterior")
plot!(analytic_posterior, label="Analytical Posterior", linewidth=2)
plot!(prior, label="Prior", linewidth=2)
xlabel!("θ"); ylabel!("Density"); title!("Posterior Distribution of θ")
