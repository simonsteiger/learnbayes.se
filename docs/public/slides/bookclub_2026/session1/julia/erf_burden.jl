using CairoMakie, Distributions, Random

const FONT_DIR = joinpath(@__DIR__, "..", "..", "fonts")
const IMG_DIR = joinpath(@__DIR__, "..", "img")

const KI_COLORS = (
    plum=colorant"#870052",
    plum_light=colorant"#EDDBE4",
    blue=colorant"#3E9196",
    grey=colorant"#666666",
)

slide_theme() = Theme(;
    fonts=(;
        regular=joinpath(FONT_DIR, "DMSans-Regular.ttf"),
        bold=joinpath(FONT_DIR, "DMSans-Bold.ttf"),
    ),
    fontsize=22,
    Axis=(;
        xgridvisible=false,
        ygridvisible=false,
        xticksvisible=false,
        yticksvisible=false,
        xticklabelsvisible=false,
        yticklabelsvisible=false,
    ),
)

rbf(x, centre; width=0.15) = exp(-((x - centre) / width)^2 / 2)

exposure_response(x, weights) = sum(w * rbf(x, c) for (w, c) in zip(weights, BASIS_CENTRES))

exposure_response2(x) = log.(x)

draw_weights(rng) = MEAN_WEIGHTS .+ rand(rng, Normal(0, WEIGHT_SD), length(MEAN_WEIGHTS))

function exposure_response_figure(n_draws=40)
    exposures = range(1, 10; length=200)
    fig = Figure(; size=(520, 420))
    ax = Axis(fig[1, 1]; xlabel="Exposure", ylabel="Response")
    for _ in 1:n_draws
        beta = rand(Normal(1, 0.1))
        lines!(
            ax,
            exposures,
            log.(exposures) .* beta; # add some random noise
            color=(KI_COLORS.plum, 0.15),
        )
    end
    lines!(
        ax,
        exposures,
        log.(exposures);
        color=KI_COLORS.plum,
        linewidth=3,
    )
    vlines!(ax, 6.0; color=KI_COLORS.grey, linestyle=:dash)
    text!(
        ax,
        6.0,
        0;
        text=rich("x", subscript("new")),
        align=(:left, :bottom),
        offset=(8, 4),
        color=KI_COLORS.grey,
    )
    ylims!(ax, 0, nothing)
    xlims!(ax, 1, 10)
    return fig
end

const BURDEN = Gamma(4, 1.5)

function burden_figure()
    burdens = range(0, quantile(BURDEN, 0.999); length=200)
    densities = pdf.(BURDEN, burdens)
    fig = Figure(; size=(520, 420))
    ax = Axis(fig[1, 1]; xlabel="Burden")
    band!(ax, burdens, zero(densities), densities; color=KI_COLORS.plum_light)
    lines!(ax, burdens, densities; color=KI_COLORS.plum, linewidth=3)
    ylims!(ax, 0, nothing)
    return fig
end

function save_figures()
    with_theme(slide_theme()) do
        save(joinpath(IMG_DIR, "exposure_response.svg"), exposure_response_figure())
        save(joinpath(IMG_DIR, "burden.svg"), burden_figure())
    end
end

save_figures()
