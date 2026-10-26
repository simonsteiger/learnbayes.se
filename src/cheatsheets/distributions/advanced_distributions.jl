include("plotting.jl")

using Random: Xoshiro

const PALETTE = (
    measurements="#5254A3",
    measurements_dark="#393B79",
    waiting="#637939",
    outcomes="#8C6D31",
    scales="#3182BD",
    correlations="#A55194",
    correlations_dark="#7B4173",
    extensions="#FD8D3C",
    extensions_dark="#E6550D",
)

# The three darkest tab20c orange shades.
const GAUSSIAN_PROCESS_COLOURS = ["#E6550D", "#FD8D3C", "#FDAE6B"]

# Backgrounds for the categories without a counterpart on the common sheet,
# matching `background` in theme.typ.
const CATEGORY_BACKGROUND = merge(
    BACKGROUND,
    (scales="#EEF4FA", correlations=BACKGROUND.probabilities, extensions="#FEF1E3"),
)

zero_inflated_poisson(π, λ) = MixtureModel([Dirac(0), Poisson(λ)], [π, 1 - π])

logistic(x) = 1 / (1 + exp(-x))

# P(y = k) for k = 1, …, K, following Turing's `OrderedLogistic(η, cutpoints)`.
function ordered_logistic(η, cutpoints)
    issorted(cutpoints) ||
        throw(ArgumentError("cutpoints must be increasing, got $cutpoints"))
    exceedance = [1; logistic.(η .- cutpoints); 0]
    return Distributions.Categorical(exceedance[1:(end-1)] .- exceedance[2:end])
end

# One off-diagonal correlation of a K × K LKJ(η) matrix: (r + 1) / 2 ~ Beta(b, b)
# with b = η - 1 + K / 2.
function lkj_correlation_marginal(K, η)
    b = η - 1 + K / 2
    return -1 + 2 * Beta(b, b)
end

# Nested regions holding `coverages` of a bivariate normal with standard
# deviations σx, σy and correlation ρ, drawn to scale.
function bivariate_normal_plot(
    name,
    hex,
    background,
    σx,
    σy,
    ρ;
    coverages=(0.99, 0.9, 0.7, 0.4),
    stroke_hex=hex,
)
    -1 < ρ < 1 ||
        throw(ArgumentError("correlation must lie strictly between -1 and 1, got $ρ"))
    fig = new_figure(background)
    ax = Axis(fig[1, 1]; backgroundcolor=background, aspect=DataAspect())
    hidedecorations!(ax)
    hidespines!(ax)
    colour = parse(RGBf, hex)
    stroke_colour = parse(RGBf, stroke_hex)
    angles = range(0, 2π; length=200)
    for coverage in coverages
        radius = sqrt(quantile(Chisq(2), coverage))
        ellipse = [
            Point2f(
                radius * σx * cos(t),
                radius * σy * (ρ * cos(t) + sqrt(1 - ρ^2) * sin(t)),
            ) for t in angles
        ]
        poly!(ax, ellipse; color=(colour, 0.3), strokecolor=stroke_colour, strokewidth=1)
    end
    half_height = 1.03 * sqrt(quantile(Chisq(2), maximum(coverages))) * σy
    half_width = half_height * FIGURE_SIZE_PT[1] / FIGURE_SIZE_PT[2]
    limits!(ax, -half_width, half_width, -half_height, half_height)
    return save_plot(name, fig)
end

function truncation_plot(name, hex, stroke_hex, background, xs, d, lower, upper)
    fig = new_figure(background)
    ax = spineless_axis(fig[1, 1], background)
    lines!(ax, xs, pdf.(d, xs); color=lighten(hex, TINT_WHITE_SHARES[3]), linewidth=1)
    inside = range(lower, upper; length=200)
    densities = pdf.(truncated(d; lower, upper), inside)
    band!(ax, inside, zero(densities), densities; color=(parse(RGBf, hex), 0.45))
    lines!(ax, inside, densities; color=parse(RGBf, stroke_hex), linewidth=1)
    xlims!(ax, first(xs), last(xs))
    ylims!(ax, 0, nothing)
    return save_plot(name, fig)
end

# The density below `upper`, and a stem at `upper` for the values censoring
# records there. The stem is `stem_vs_limit` times the density at `upper`: an
# illustration of the bunching, not to scale with the probability it stands
# for. The uncensored density is drawn faintly underneath.
function right_censoring_plot(
    name,
    hex,
    stroke_hex,
    background,
    xs,
    d,
    upper;
    stem_vs_limit,
)
    fig = new_figure(background)
    ax = spineless_axis(fig[1, 1], background)
    stroke_colour = parse(RGBf, stroke_hex)
    lines!(ax, xs, pdf.(d, xs); color=lighten(hex, TINT_WHITE_SHARES[3]), linewidth=1)
    observed = range(first(xs), upper; length=200)
    densities = pdf.(d, observed)
    band!(ax, observed, zero(densities), densities; color=(parse(RGBf, hex), 0.45))
    lines!(ax, observed, densities; color=stroke_colour, linewidth=1)
    styled_stem!(ax, [upper], [stem_vs_limit * pdf(d, upper)], stroke_colour)
    xlims!(ax, first(xs), last(xs))
    ylims!(ax, 0, nothing)
    return save_plot(name, fig)
end

squared_exponential(x, x′; α, ℓ) = α^2 * exp(-(x - x′)^2 / (2 * ℓ^2))

# Draws from a zero-mean Gaussian process with a squared exponential kernel, one
# per colour.
function gaussian_process_plot(name, colours, background, xs; α, ℓ, seed=1)
    n_draws = length(colours)
    jitter = 1e-6
    covariance = [
        squared_exponential(xs[i], xs[j]; α, ℓ) + (i == j) * jitter for
        i in eachindex(xs), j in eachindex(xs)
    ]
    draws = rand(Xoshiro(seed), MvNormal(zeros(length(xs)), covariance), n_draws)
    fig = new_figure(background)
    ax = spineless_axis(fig[1, 1], background)
    for (draw, draw_colour) in zip(eachcol(draws), colours)
        lines!(ax, xs, draw; color=draw_colour, linewidth=1)
    end
    xlims!(ax, first(xs), last(xs))
    return save_plot(name, fig)
end

function make_all_plots()
    mkpath(IMG_DIR)
    p = PALETTE
    bg = CATEGORY_BACKGROUND
    return [
        pdf_plot(
            "laplace",
            p.measurements,
            bg.measurements,
            range(-5, 5; length=300),
            Laplace(0, 1);
            stroke_hex=p.measurements_dark,
        ),
        pdf_plot(
            "cauchy",
            p.measurements,
            bg.measurements,
            range(-5, 5; length=300),
            Cauchy(0, 1);
            stroke_hex=p.measurements_dark,
        ),
        pdf_plot(
            "lognormal",
            p.measurements,
            bg.measurements,
            range(0, 4; length=300),
            LogNormal(0, 0.5);
            stroke_hex=p.measurements_dark,
        ),
        pdf_plot("weibull", p.waiting, bg.waiting, range(0, 3; length=300), Weibull(2, 1)),
        pmf_plot(
            "orderedlogistic",
            [p.outcomes],
            bg.outcomes,
            1:5,
            [ordered_logistic(0.5, [-2, -0.5, 1, 2.5])],
        ),
        pdf_plot(
            "inversegamma",
            p.scales,
            bg.scales,
            range(0.01, 3; length=300),
            InverseGamma(3, 2),
        ),
        bivariate_normal_plot(
            "mvnormal",
            p.correlations,
            bg.correlations,
            2,
            1,
            0.7;
            stroke_hex=p.correlations_dark,
        ),
        pdf_plot(
            "lkj",
            p.correlations,
            bg.correlations,
            range(-1, 1; length=300),
            lkj_correlation_marginal(2, 2);
            stroke_hex=p.correlations_dark,
        ),
        pmf_plot(
            "mixture",
            [p.extensions_dark],
            bg.extensions,
            0:15,
            [zero_inflated_poisson(0.3, 4)],
        ),
        truncation_plot(
            "truncated",
            p.extensions,
            p.extensions_dark,
            bg.extensions,
            range(-3, 3; length=300),
            Normal(0, 1),
            -0.5,
            1.5,
        ),
        right_censoring_plot(
            "censored",
            p.extensions,
            p.extensions_dark,
            bg.extensions,
            range(-3, 3; length=300),
            Normal(0, 1),
            1;
            stem_vs_limit=3.3,
        ),
        gaussian_process_plot(
            "gaussianprocess",
            GAUSSIAN_PROCESS_COLOURS,
            bg.extensions,
            range(0, 10; length=200);
            α=1,
            ℓ=1,
        ),
    ]
end

make_all_plots()
