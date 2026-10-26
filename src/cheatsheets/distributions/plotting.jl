using CairoMakie
using Distributions

# Category backgrounds, matching `background` in theme.typ.
const BACKGROUND = (
    outcomes="#F8EFDF",
    counts="#F8E0E1",
    waiting="#F0F4E1",
    measurements="#E1E2F5",
    probabilities="#F5E2F3",
)

const FIGURE_SIZE_PT = (110, 50)
const IMG_DIR = joinpath(@__DIR__, "img")

const TINT_WHITE_SHARES = (0.0, 0.3, 0.55)

function lighten(hex, white_share)
    rgb = parse(RGBf, hex)
    mix(channel) = channel + (1 - channel) * white_share
    return RGBf(mix(rgb.r), mix(rgb.g), mix(rgb.b))
end

tints(hex, n) = [lighten(hex, TINT_WHITE_SHARES[i]) for i in 1:n]

darkest(hexes) = argmin(hex -> CairoMakie.Colors.Lab(parse(RGBf, hex)).l, hexes)

# The bottom spine takes the darkest colour in the plot.
function bare_axis(gridposition, background, colours)
    ax = Axis(
        gridposition;
        backgroundcolor=background,
        bottomspinecolor=darkest(colours),
        spinewidth=0.75,
    )
    hidedecorations!(ax)
    hidespines!(ax, :t, :l, :r)
    return ax
end

function spineless_axis(gridposition, background)
    ax = Axis(gridposition; backgroundcolor=background)
    hidedecorations!(ax)
    hidespines!(ax)
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

function styled_stem!(ax, xs, heights, colour)
    return stem!(
        ax,
        xs,
        heights;
        color=colour,
        stemcolor=colour,
        stemwidth=1,
        markersize=5,
        trunkwidth=0,
    )
end

function pmf_plot(name, colours, background, support, dists)
    length(colours) == length(dists) || throw(
        ArgumentError(
            "need one colour per distribution, got $(length(colours)) colours for $(length(dists)) distributions",
        ),
    )
    fig = new_figure(background)
    ax = bare_axis(fig[1, 1], background, colours)
    for (d, colour, offset) in zip(dists, colours, stem_offsets(length(dists)))
        styled_stem!(ax, support .+ offset, pdf.(d, support), colour)
    end
    xlims!(ax, first(support) - 0.5, last(support) + 0.5)
    ylims!(ax, 0, nothing)
    return save_plot(name, fig)
end

function pdf_plot(name, hex, background, xs, d; stroke_hex=hex)
    fig = new_figure(background)
    ax = spineless_axis(fig[1, 1], background)
    densities = pdf.(d, xs)
    band!(ax, xs, zero(densities), densities; color=(parse(RGBf, hex), 0.45))
    lines!(ax, xs, densities; color=parse(RGBf, stroke_hex), linewidth=1)
    xlims!(ax, first(xs), last(xs))
    ylims!(ax, 0, nothing)
    return save_plot(name, fig)
end
