using GLMakie, Distributions, Random

const COLORS = Makie.wong_colors()

# Fixed so that axes keep their size when the tick labels change width.
const YTICKLABELSPACE = 30.0

struct Config
    prior::Beta{Float64}
    θ_true::Float64
    n::Int
    k::Int
    grid_res::Int
end

function simulate(rng, α, β, θ_true, n, grid_res)
    k = rand(rng, Binomial(n, θ_true))
    return Config(Beta(α, β), θ_true, n, k, grid_res)
end

simulate(α, β, θ_true, n, grid_res) =
    simulate(Random.default_rng(), α, β, θ_true, n, grid_res)

n_failures(c) = c.n - c.k

normalised_likelihood(c) = Beta(c.k + 1, n_failures(c) + 1)

posterior(c) = Beta(c.prior.α + c.k, c.prior.β + n_failures(c))

#=
θ_grid(c) = range(0, 1; length=c.grid_res)

function grid_likelihood(c::Config)
    likelihoods = map(θ -> pdf(Binomial(c.n, θ), c.k), θ_grid(c))
    return likelihoods ./ sum(likelihoods)
end

grid_points(c) = Point2f.(θ_grid(c), grid_likelihood(c))

likelihood_title(c) = "Likelihood (N = $(c.n), k = $(c.k))"

function grid_ticks(c::Config)
    θs = θ_grid(c)
    return (collect(θs), string.(round.(θs; digits=2)))
end

function prior_panel!(position, c::Config)
    ax = Axis(
        position;
        title="Prior",
        xlabel="Probability (θ)",
        ylabel="Density",
        limits=((0, 1), (0, nothing)),
        yticklabelspace=YTICKLABELSPACE,
    )
    prior = plot!(ax, c.prior; color=COLORS[1])
    return (; ax, prior, hideable_scenes=(ax.scene,))
end

function update_prior_panel!(panel, c::Config)
    Makie.update!(panel.prior; arg1=c.prior)
    reset_limits!(panel.ax)
    return panel
end

function likelihood_panel!(position, c::Config)
    ax = Axis(
        position;
        title=likelihood_title(c),
        xlabel="Probability (θ)",
        ylabel="Normalised likelihood",
        limits=((-0.15, 1.15), (0, 1)),
        yticklabelspace=YTICKLABELSPACE,
        xticks=grid_ticks(c),
    )
    bars = barplot!(ax, grid_points(c); color=COLORS[2])
    return (; ax, bars, hideable_scenes=(ax.scene,))
end

function update_likelihood_panel!(panel, c::Config)
    panel.ax.title = likelihood_title(c)
    panel.ax.xticks = grid_ticks(c)
    Makie.update!(panel.bars; arg1=grid_points(c))
    return panel
end
=#

function posterior_panel!(position, c::Config)
    ax = Axis(
        position;
        title="Posterior",
        xlabel="Probability (θ)",
        ylabel="Density",
        limits=((0, 1), (0, nothing)),
        yticklabelspace=YTICKLABELSPACE,
    )
    prior = plot!(ax, c.prior; label="Prior", color=COLORS[1])
    likelihood = plot!(ax, normalised_likelihood(c); label="Likelihood", color=COLORS[2])
    posterior_plot = plot!(ax, posterior(c); label="Posterior", color=COLORS[3])
    truth = vlines!(ax, c.θ_true; label="Truth", color=:black, linestyle=:dash)
    legend = axislegend(ax)
    hideable_scenes = (ax.scene, legend.blockscene)
    return (; ax, prior, likelihood, posterior=posterior_plot, truth, hideable_scenes)
end

function update_posterior_panel!(panel, c::Config)
    Makie.update!(panel.prior; arg1=c.prior)
    Makie.update!(panel.likelihood; arg1=normalised_likelihood(c))
    Makie.update!(panel.posterior; arg1=posterior(c))
    Makie.update!(panel.truth; arg1=c.θ_true)
    reset_limits!(panel.ax)
    return panel
end

#=
function panel_checkbox!(position, panel)
    layout = GridLayout(position; tellwidth=false)
    checkbox = Checkbox(layout[1, 1]; checked=false)
    Label(layout[1, 2], "Show"; halign=:left)
    colgap!(layout, 8)
    on(checkbox.checked; update=true) do is_checked
        for scene in panel.hideable_scenes
            scene.visible[] = is_checked
        end
    end
    return checkbox
end
=#

function explore_bayes(; seed=42)
    fig = Figure()

    slider_grid = SliderGrid(
        fig[2, 1],
        (label="Prior α", range=1:0.1:50, startvalue=2),
        (label="Prior β", range=1:0.1:50, startvalue=2),
        (label="True θ", range=0:0.01:1, startvalue=0.3),
        (label="Trials N", range=0:1:200, startvalue=10),
        (label="Grid resolution", range=3:1:10, startvalue=5);
        width=500,
        tellwidth=false,
    )
    slider_values = [slider.value for slider in slider_grid.sliders]
    initial_c = simulate(Xoshiro(seed), to_value.(slider_values)...)

    # prior_panel = prior_panel!(fig[1, 1], initial_c)
    # likelihood_panel = likelihood_panel!(fig[1, 2], initial_c)
    posterior_panel = posterior_panel!(fig[1, 1], initial_c)

    # panel_checkbox!(fig[2, 1], prior_panel)
    # panel_checkbox!(fig[2, 2], likelihood_panel)
    # panel_checkbox!(fig[2, 3], posterior_panel)

    onany(slider_values...) do α, β, θ_true, n, grid_res
        c = simulate(Xoshiro(seed), α, β, θ_true, n, grid_res)
        # update_prior_panel!(prior_panel, c::Config)
        # update_likelihood_panel!(likelihood_panel, c::Config)
        update_posterior_panel!(posterior_panel, c::Config)
    end

    return fig
end

display(explore_bayes())
