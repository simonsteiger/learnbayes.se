using CairoMakie
using Distributions
using Colors

function sample_mvn(cor)
	Σ = [1 cor; cor 1]
	μ = zeros(size(Σ, 1))
	mvn = MvNormal(μ, Σ)
	X = range(-3, 3, length=200)
	Y = range(-3, 3, length=200)
	Z = [pdf(mvn, [x,y]) for y in Y, x in X]
	return X, Y, Z
end

n_colors = 100
ki_colors = [colorant"#870052", colorant"#FF876F", colorant"#FFDDD6"]

function plot_mvn_logo(colors; n_colors=100)
	base_colormap = cgrad(colors, n_colors, categorical = false)
	fig = Figure(size=(500,500), backgroundcolor=:transparent)
	ax = Axis(fig[1, 1], aspect=1.0, backgroundcolor=:transparent)
	for (i, α) in zip(0.0:0.2:0.4, [0.3, 0.5, 1])
		transparent_colormap = [RGBA(c.r, c.g, c.b, α) for c in base_colormap]
		contourf!(sample_mvn(i)..., levels = 0.1:0.15:1, mode = :relative, colormap = transparent_colormap)
	end
	hidedecorations!(ax)
	hidespines!(ax)
	return fig
end

fig = plot_mvn_logo(ki_colors)
save("mvn_splash.svg", fig)
