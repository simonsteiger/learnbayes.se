using CairoMakie
using Distributions

const PALETTE = (
    outcomes="#BD9E39",
    poisson_family="#AD494A",
    geometric="#8CA252",
    exponential_family="#637939",
    normal="#5254A3",
    beta="#A55194",
)

const BACKGROUND = (
    outcomes="#F8EFDF",
    counts="#F8E0E1",
    waiting="#F0F4E1",
    measurements="#E1E2F5",
    probabilities="#F5E2F3",
)

# The tab20b ochre shades with the highest contrast against BACKGROUND.outcomes.
const MULTINOMIAL_COLOURS = ["#8C6D31", "#BD9E39", "#E7BA52"]

const SPINE_COLOUR = "#8B8B8B"
const FIGURE_SIZE_PT = (110, 50)
const IMG_DIR = joinpath(@__DIR__, "img")

const TINT_WHITE_SHARES = (0.0, 0.3, 0.55)

function lighten(hex, white_share)
    rgb = parse(RGBf, hex)
    mix(channel) = channel + (1 - channel) * white_share
    return RGBf(mix(rgb.r), mix(rgb.g), mix(rgb.b))
end

tints(hex, n) = [lighten(hex, TINT_WHITE_SHARES[i]) for i in 1:n]

function bare_axis(gridposition, background)
    ax = Axis(
        gridposition;
        backgroundcolor=background,
        bottomspinecolor=SPINE_COLOUR,
        spinewidth=0.75,
    )
    hidedecorations!(ax)
    hidespines!(ax, :t, :l, :r)
    return ax
end

function new_figure(background)
    return Figure(; size=FIGURE_SIZE_PT, figure_padding=2, backgroundcolor=background)
end

function save_plot(name, fig)
    path = joinpath(IMG_DIR, name * ".svg")
    save(path, fig; pt_per_unit=1)
    return path
end

const STEM_SPACING = 0.3

stem_offsets(n) = ((1:n) .- (n + 1) / 2) .* STEM_SPACING

function pmf_plot(name, colours, background, support, dists)
    length(colours) == length(dists) || throw(
        ArgumentError(
            "need one colour per distribution, got $(length(colours)) colours for $(length(dists)) distributions",
        ),
    )
    fig = new_figure(background)
    ax = bare_axis(fig[1, 1], background)
    for (d, colour, offset) in zip(dists, colours, stem_offsets(length(dists)))
        stem!(
            ax,
            support .+ offset,
            pdf.(d, support);
            color=colour,
            stemcolor=colour,
            stemwidth=1,
            markersize=5,
            trunkwidth=0,
        )
    end
    xlims!(ax, first(support) - 0.5, last(support) + 0.5)
    ylims!(ax, 0, nothing)
    return save_plot(name, fig)
end

function pdf_plot(name, hex, background, xs, d)
    fig = new_figure(background)
    ax = bare_axis(fig[1, 1], background)
    colour = parse(RGBf, hex)
    densities = pdf.(d, xs)
    band!(ax, xs, zero(densities), densities; color=(colour, 0.45))
    lines!(ax, xs, densities; color=colour, linewidth=1)
    xlims!(ax, first(xs), last(xs))
    ylims!(ax, 0, nothing)
    return save_plot(name, fig)
end

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
    ax = Axis(fig[1, 1]; backgroundcolor=background)
    hidedecorations!(ax)
    hidespines!(ax)
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
            Normal(0, 1),
        ),
        pdf_plot(
            "studentt",
            p.normal,
            bg.measurements,
            range(-5, 5; length=300),
            studentt_from_location_scale(3, 0, 1),
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
        pdf_plot("beta", p.beta, bg.probabilities, range(0, 1; length=300), Beta(2, 5)),
        partition_plot("dirichlet", p.beta, bg.probabilities, (0.2, 0.5, 0.3)),
    ]
end

make_all_plots()
