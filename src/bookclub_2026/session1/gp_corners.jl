using AbstractGPs, CairoMakie, Random

const TEMPLATE_DIR = joinpath(@__DIR__, "..", "template")
const TYRIAN_PURPLE = colorant"#870052"
const SLIDE_WIDTH = 16
const SLIDE_HEIGHT = 9
const PIXELS_PER_SLIDE_UNIT = 60

sekernel(lengthscale, variance) =
    variance * with_lengthscale(SqExponentialKernel(), lengthscale)

conditioned_on(gp, observation; noise_variance=0.005) =
    posterior(gp([observation.x], noise_variance), [observation.y])

# One sample path per column.
sample_paths(rng, gp, xs; n_samples, jitter=1e-6) = rand(rng, gp(xs, jitter), n_samples)

is_on_slide(point) = 0 <= point[1] <= SLIDE_WIDTH && 0 <= point[2] <= SLIDE_HEIGHT

function path_on_slide(xs, path; edge_crossings, x_centre, slide_units_per_gp_unit)
    first_crossing, second_crossing = Point2f.(edge_crossings)
    midpoint = (first_crossing + second_crossing) / 2
    along =
        (second_crossing - first_crossing) / hypot((second_crossing - first_crossing)...)
    across = Point2f(-along[2], along[1])
    points = [
        midpoint + slide_units_per_gp_unit * ((x - x_centre) * along + y * across) for
        (x, y) in zip(xs, path)
    ]
    if is_on_slide(first(points)) || is_on_slide(last(points))
        error(
            "a sample path ends on the slide at $(first(points)) or $(last(points)); " *
            "widen the range of `xs` so that every path leaves the slide",
        )
    end
    return points
end

function corner_lines_figure(;
    xs=-3:0.05:13,
    x_centre=5,
    slide_units_per_gp_unit=1.0,
    n_samples=10,
    variance=1.0,
    lengthscale=1.5,
    # Negative `y` points from each corner towards the centre of the slide.
    observation=(x=x_centre, y=-2.5),
    corners=(
        (edge_crossings=((12.5, 9), (16, 6)), rng=Xoshiro(1)),
        (edge_crossings=((3.5, 0), (0, 3)), rng=Xoshiro(2)),
    ),
)
    conditioned_gp = conditioned_on(GP(sekernel(lengthscale, variance)), observation)
    fig = Figure(;
        size=PIXELS_PER_SLIDE_UNIT .* (SLIDE_WIDTH, SLIDE_HEIGHT),
        figure_padding=0,
        backgroundcolor=:white,
    )
    ax = Axis(fig[1, 1]; limits=(0, SLIDE_WIDTH, 0, SLIDE_HEIGHT), backgroundcolor=:white)
    for (; edge_crossings, rng) in corners
        paths = sample_paths(rng, conditioned_gp, xs; n_samples)
        for (path_number, path) in enumerate(eachcol(paths))
            points =
                path_on_slide(xs, path; edge_crossings, x_centre, slide_units_per_gp_unit)
            lines!(
                ax,
                points;
                color=(TYRIAN_PURPLE, path_number / (n_samples * 1.5)),
                linewidth=1,
            )
        end
    end
    hidedecorations!(ax)
    hidespines!(ax)
    return fig
end

save(joinpath(TEMPLATE_DIR, "gp-corners.svg"), corner_lines_figure())
