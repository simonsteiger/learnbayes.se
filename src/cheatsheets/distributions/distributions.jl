include("plotting.jl")

const PALETTE = (
    outcomes="#8C6D31",
    poisson_family="#843C39",
    geometric="#637939",
    exponential_family="#637939",
    normal="#5254A3",
    normal_dark="#393B79",
    beta="#A55194",
    beta_dark="#7B4173",
)

# The tab20b ochre shades with the highest contrast against BACKGROUND.outcomes.
const MULTINOMIAL_COLOURS = ["#8C6D31", "#BD9E39", "#E7BA52"]

exponential_from_rate(λ) = Exponential(1 / λ)
gamma_from_shape_rate(α, β) = Gamma(α, 1 / β)
negbinomial_from_mean_dispersion(μ, ϕ) = NegativeBinomial(ϕ, ϕ / (ϕ + μ))
studentt_from_location_scale(ν, μ, σ) = μ + σ * TDist(ν)

function multinomial_plot(name, colours, background, n, θ)
    marginals = [Binomial(n, θk) for θk in θ]
    return pmf_plot(name, colours, background, 0:n, marginals)
end

function partition_plot(name, hex, background, θ)
    sum(θ) ≈ 1 || throw(ArgumentError("θ must sum to 1, got sum $(sum(θ))"))
    segment_starts = cumsum([0; collect(θ)[1:(end-1)]])
    segments = [Rect2f(start, 0.3, width, 0.4) for (start, width) in zip(segment_starts, θ)]

    fig = new_figure(background)
    ax = spineless_axis(fig[1, 1], background)
    poly!(ax, segments; color=tints(hex, length(θ)), strokecolor=background, strokewidth=1)
    limits!(ax, 0, 1, 0, 1)
    return save_plot(name, fig)
end

function make_all_plots()
    mkpath(IMG_DIR)
    p = PALETTE
    bg = BACKGROUND
    return [
        pdf_plot(
            "normal",
            p.normal,
            bg.measurements,
            range(-5, 5; length=300),
            Normal(0, 1);
            stroke_hex=p.normal_dark,
        ),
        pdf_plot(
            "studentt",
            p.normal,
            bg.measurements,
            range(-5, 5; length=300),
            studentt_from_location_scale(3, 0, 1);
            stroke_hex=p.normal_dark,
        ),
        pdf_plot(
            "exponential",
            p.exponential_family,
            bg.waiting,
            range(0, 5; length=300),
            exponential_from_rate(1),
        ),
        pdf_plot(
            "gamma",
            p.exponential_family,
            bg.waiting,
            range(0, 10; length=300),
            gamma_from_shape_rate(3, 1),
        ),
        pmf_plot("geometric", [p.geometric], bg.waiting, 0:10, [Geometric(0.2)]),
        pmf_plot("bernoulli", [p.outcomes], bg.outcomes, 0:1, [Bernoulli(0.3)]),
        pmf_plot("binomial", [p.outcomes], bg.outcomes, 0:10, [Binomial(10, 0.2)]),
        pmf_plot("poisson", [p.poisson_family], bg.counts, 0:20, [Poisson(4)]),
        pmf_plot(
            "negbinomial",
            [p.poisson_family],
            bg.counts,
            0:20,
            [negbinomial_from_mean_dispersion(6, 5)],
        ),
        pmf_plot(
            "categorical",
            [p.outcomes],
            bg.outcomes,
            1:4,
            [Distributions.Categorical([0.1, 0.4, 0.3, 0.2])],
        ),
        multinomial_plot(
            "multinomial",
            MULTINOMIAL_COLOURS,
            bg.outcomes,
            10,
            (0.1, 0.3, 0.6),
        ),
        pdf_plot(
            "beta",
            p.beta,
            bg.probabilities,
            range(0, 1; length=300),
            Beta(2, 5);
            stroke_hex=p.beta_dark,
        ),
        partition_plot("dirichlet", p.beta, bg.probabilities, (0.2, 0.5, 0.3)),
    ]
end

make_all_plots()
