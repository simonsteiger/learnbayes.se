### A Pluto.jl notebook ###
# v1.0.4

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ 1d2354be-c2e2-11f1-8695-4d7fb95822dc
using CairoMakie

# ╔═╡ 2a6f0c14-3b7d-4e19-9c52-6d1e8f4a7b01
using Distributions

# ╔═╡ 3b8e1d25-4c8e-4f2a-8d63-7e2f9a5b8c02
using Random

# ╔═╡ 4c9f2e36-5d9f-4a3b-9e74-8f3a0b6c9d03
using PlutoUI

# ╔═╡ 5da03f47-6ea0-4b4c-8f85-904b1c7dae04
using HypertextLiteral

# ╔═╡ 6eb14058-7fb1-4c5d-9a96-a15c2d8ebf05
md"""
# Prior
"""

# ╔═╡ a2f58492-b3f5-4091-9eda-e5906102f309
md"""
# Likelihood
"""

# ╔═╡ d528b7c5-e628-43c4-8b0d-18c39435260c
md"""
# Putting it together
"""

# ╔═╡ 075ad9e7-084a-45e6-8d2f-3ae5b657480e
md"""
# Code

## Model
"""

# ╔═╡ 186beaf8-195b-46f7-9e30-4bf6c768590f
seed = 42

# ╔═╡ 297cfb09-2a6c-4708-8f41-5c07d8796a10
struct Config
    prior::Beta{Float64}
    θ_true::Float64
    n::Int
    k::Int
    grid_res::Int
end

# ╔═╡ 3a8d0c1a-3b7d-4819-9052-6d18e98a7b11
function simulate(rng, α, β, θ_true, n, grid_res)
    k = rand(rng, Binomial(n, θ_true))
    return Config(Beta(α, β), θ_true, n, k, grid_res)
end

# ╔═╡ 4b9e1d2b-4c8e-492a-8163-7e29fa9b8c12
n_failures(c) = c.n - c.k

# ╔═╡ 5caf2e3c-5d9f-4a3b-9274-8f3a0bac9d13
normalised_likelihood(c) = Beta(c.k + 1, n_failures(c) + 1)

# ╔═╡ 6db03f4d-6ea0-4b4c-8385-904b1cbdae14
posterior(c) = Beta(c.prior.α + c.k, c.prior.β + n_failures(c))

# ╔═╡ 7ec1405e-7fb1-4c5d-9496-a15c2dcebf15
θ_grid(c) = range(0, 1; length=c.grid_res)

# ╔═╡ 8fd2516f-80c2-4d6e-85a7-b26d3edfc016
function grid_likelihood(c::Config)
    likelihoods = map(θ -> pdf(Binomial(c.n, θ), c.k), θ_grid(c))
    return likelihoods ./ sum(likelihoods)
end

# ╔═╡ 90e36270-91d3-4e7f-96b8-c37e4fe0d117
grid_points(c) = Point2f.(θ_grid(c), grid_likelihood(c))

# ╔═╡ a1f47381-a2e4-4f80-87c9-d48f50f1e218
md"""
## Plotting
"""

# ╔═╡ b2058492-b3f5-4091-98da-e5906102f319
const COLORS = Makie.wong_colors()

# ╔═╡ c31695a3-c406-41a2-89eb-f6a17213041a
const YTICKLABELSPACE = 30.0

# ╔═╡ e538b7c5-e628-43c4-8b0d-18c39435261c
function grid_ticks(c::Config)
    θs = θ_grid(c)
    return (collect(θs), string.(round.(θs; digits=2)))
end

# ╔═╡ f649c8d6-f739-44d5-9c1e-29d4a546371d
function prior_panel!(position, c::Config)
    ax = Axis(
        position;
        title="Prior",
        xlabel="p(θ)",
        ylabel="Density",
        limits=((0, 1), (0, nothing)),
        yticklabelspace=YTICKLABELSPACE,
    )
    prior = plot!(ax, c.prior; color=COLORS[1])
    return (; ax, prior)
end

# ╔═╡ 075ad9e7-084a-45e6-8d2f-3ae5b657481e
function likelihood_panel!(position, c::Config)
    ax = Axis(
        position;
        title="Likelihood (trials = $(c.n), successes = $(c.k))",
        xlabel="p(θ)",
        ylabel="Normalised likelihood",
        limits=((-0.15, 1.15), (0, 1)),
        yticklabelspace=YTICKLABELSPACE,
        xticks=grid_ticks(c),
    )
    bars = barplot!(ax, grid_points(c); color=COLORS[2])
    return (; ax, bars)
end

# ╔═╡ 186beaf8-195b-46f7-9e30-4bf6c768591f
function posterior_panel!(position, c::Config)
    ax = Axis(
        position;
        title="Posterior",
        xlabel="p(θ)",
        ylabel="Density",
        limits=((0, 1), (0, nothing)),
        yticklabelspace=YTICKLABELSPACE,
    )
    prior = plot!(ax, c.prior; label="Prior", color=COLORS[1])
    likelihood = plot!(ax, normalised_likelihood(c); label="Likelihood", color=COLORS[2])
    posterior_plot = plot!(ax, posterior(c); label="Posterior", color=COLORS[3])
    truth = vlines!(ax, c.θ_true; label="Truth", color=:black, linestyle=:dash)
    axislegend(ax)
    return (; ax, prior, likelihood, posterior=posterior_plot, truth)
end

# ╔═╡ 297cfb09-2a6c-4708-8f41-5c07d8796a20
md"""
## Controls
"""

# ╔═╡ 3a8d0c1a-3b7d-4819-9052-6d18e98a7b21
begin
    α_slider = @bind α PlutoUI.Slider(1:1:50; default=2, show_value=true)
    β_slider = @bind β PlutoUI.Slider(1:1:50; default=2, show_value=true)
    θ_true_slider = @bind θ_true PlutoUI.Slider(0:0.1:1; default=0.3, show_value=true)
    n_slider = @bind n PlutoUI.Slider(0:1:200; default=10, show_value=true)
    grid_res_slider = @bind grid_res PlutoUI.Slider(3:1:10; default=5, show_value=true)
    nothing
end

# ╔═╡ 4b9e1d2b-4c8e-492a-8163-7e29fa9b8c22
c = simulate(Xoshiro(seed), α, β, θ_true, n, grid_res)

# ╔═╡ 8fd2516f-80c2-4d6e-85a7-b26d3edfc007
let
    fig = Figure()
    prior_panel!(fig[1, 1], c)
    fig
end

# ╔═╡ c417a6b4-d517-42b3-9afc-07b28324150b
let
    fig = Figure()
    likelihood_panel!(fig[1, 1], c)
    fig
end

# ╔═╡ f649c8d6-f739-44d5-9c1e-29d4a546370d
let
    fig = Figure()
    posterior_panel!(fig[1, 1], c)
    fig
end

# ╔═╡ 5caf2e3c-5d9f-4a3b-9274-8f3a0bac9d23
box_style = "flex:1 1 15rem;padding:1rem;background-color:#f0f0f0;color:#222;border-radius:5px;border:solid #d1d1d1 2px;"

# ╔═╡ 6db03f4d-6ea0-4b4c-8385-904b1cbdae24
control_box(title, description, slider) = @htl("""
<div style=$(box_style)>
<h4 style="color:#222;">$(title)</h4>
<p>&rarr; $(description)</p>
$(slider)
</div>
""")

# ╔═╡ 7ec1405e-7fb1-4c5d-9496-a15c2dcebf25
controls(boxes...) = @htl("""
<div style="display:flex;flex-wrap:wrap;gap:1rem;margin-top:1rem;">
$(boxes)
</div>
""")

# ╔═╡ 8fd2516f-80c2-4d6e-85a7-b26d3edfc026
α_box = control_box("Prior α", "Number of prior successes.", α_slider)

# ╔═╡ 90e36270-91d3-4e7f-96b8-c37e4fe0d127
β_box = control_box("Prior β", "Number of prior failures.", β_slider)

# ╔═╡ 7fc25169-80c2-4d6e-8ba7-b26d3e9fc006
controls(α_box, β_box)

# ╔═╡ a1f47381-a2e4-4f80-87c9-d48f50f1e228
θ_true_box =
    control_box("True θ", "True success probability.", θ_true_slider)

# ╔═╡ b2058492-b3f5-4091-98da-e5906102f329
n_box = control_box("Trials N", "Number of simulated trials.", n_slider)

# ╔═╡ e538b7c5-e628-43c4-8b0d-18c39435260d
controls(α_box, β_box, θ_true_box, n_box)

# ╔═╡ c31695a3-c406-41a2-89eb-f6a17213042a
grid_res_box = control_box(
    "Grid resolution",
    "Number of θ values at which the likelihood is evaluated.",
    grid_res_slider,
)

# ╔═╡ b30695a3-c406-41a2-89eb-f6a17213040a
controls(θ_true_box, n_box, grid_res_box)

# ╔═╡ Cell order:
# ╟─6eb14058-7fb1-4c5d-9a96-a15c2d8ebf05
# ╟─7fc25169-80c2-4d6e-8ba7-b26d3e9fc006
# ╟─8fd2516f-80c2-4d6e-85a7-b26d3edfc007
# ╟─a2f58492-b3f5-4091-9eda-e5906102f309
# ╟─b30695a3-c406-41a2-89eb-f6a17213040a
# ╟─c417a6b4-d517-42b3-9afc-07b28324150b
# ╟─d528b7c5-e628-43c4-8b0d-18c39435260c
# ╟─e538b7c5-e628-43c4-8b0d-18c39435260d
# ╟─f649c8d6-f739-44d5-9c1e-29d4a546370d
# ╟─075ad9e7-084a-45e6-8d2f-3ae5b657480e
# ╠═1d2354be-c2e2-11f1-8695-4d7fb95822dc
# ╠═2a6f0c14-3b7d-4e19-9c52-6d1e8f4a7b01
# ╠═3b8e1d25-4c8e-4f2a-8d63-7e2f9a5b8c02
# ╠═4c9f2e36-5d9f-4a3b-9e74-8f3a0b6c9d03
# ╠═5da03f47-6ea0-4b4c-8f85-904b1c7dae04
# ╠═186beaf8-195b-46f7-9e30-4bf6c768590f
# ╠═297cfb09-2a6c-4708-8f41-5c07d8796a10
# ╠═3a8d0c1a-3b7d-4819-9052-6d18e98a7b11
# ╠═4b9e1d2b-4c8e-492a-8163-7e29fa9b8c22
# ╠═4b9e1d2b-4c8e-492a-8163-7e29fa9b8c12
# ╠═5caf2e3c-5d9f-4a3b-9274-8f3a0bac9d13
# ╠═6db03f4d-6ea0-4b4c-8385-904b1cbdae14
# ╠═7ec1405e-7fb1-4c5d-9496-a15c2dcebf15
# ╠═8fd2516f-80c2-4d6e-85a7-b26d3edfc016
# ╠═90e36270-91d3-4e7f-96b8-c37e4fe0d117
# ╟─a1f47381-a2e4-4f80-87c9-d48f50f1e218
# ╠═b2058492-b3f5-4091-98da-e5906102f319
# ╠═c31695a3-c406-41a2-89eb-f6a17213041a
# ╠═e538b7c5-e628-43c4-8b0d-18c39435261c
# ╠═f649c8d6-f739-44d5-9c1e-29d4a546371d
# ╠═075ad9e7-084a-45e6-8d2f-3ae5b657481e
# ╠═186beaf8-195b-46f7-9e30-4bf6c768591f
# ╟─297cfb09-2a6c-4708-8f41-5c07d8796a20
# ╠═3a8d0c1a-3b7d-4819-9052-6d18e98a7b21
# ╠═5caf2e3c-5d9f-4a3b-9274-8f3a0bac9d23
# ╠═6db03f4d-6ea0-4b4c-8385-904b1cbdae24
# ╠═7ec1405e-7fb1-4c5d-9496-a15c2dcebf25
# ╠═8fd2516f-80c2-4d6e-85a7-b26d3edfc026
# ╠═90e36270-91d3-4e7f-96b8-c37e4fe0d127
# ╠═a1f47381-a2e4-4f80-87c9-d48f50f1e228
# ╠═b2058492-b3f5-4091-98da-e5906102f329
# ╠═c31695a3-c406-41a2-89eb-f6a17213042a
