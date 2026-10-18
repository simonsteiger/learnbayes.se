#import "@preview/touying:0.6.1": *
#import "template/ki.typ": *

#show: ki-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: "Learn Bayes book club",
    subtitle: "Session 1",
    date: "2026-10-14",
  ),
)

#title-slide()

#let big-formula(content) = {
  align(horizon, text(font-size.large, content))
}

#set raw(syntaxes: "template/stan.sublime-syntax")

// The SVG files differ in aspect ratio and in the empty space around the logo.
// `height` makes the visible logos similarly large; `top` and `right` are that
// empty space as a fraction of the height, so the visible logo can be moved
// flush with the corner of the panel's inset.
#let code-icons = (
  r: (height: 2.25em, top: 0.005, right: 0),
  stan: (height: 3.25em, top: 0.09, right: 0.09),
  python: (height: 3em, top: 0.08, right: 0.08),
  julia: (height: 3.1em, top: 0.115, right: 0.08),
)

#let code-icon(name) = {
  let (height, top, right) = code-icons.at(name)
  move(dx: right * height, dy: -top * height, image("img/" + name + ".svg", height: height))
}

// Transparency keeps the hue of each syntax-highlighted token.
#let faded(body) = {
  show text: it => context {
    set text(fill: text.fill.transparentize(60%))
    it
  }
  body
}

#let numbered-line(line, highlight) = context {
  let number-width = measure(str(line.count)).width
  let number = box(width: number-width, align(right, text(fill: ki-colors.grey, str(line.number))))
  let numbered = number + h(1em) + line.body
  if highlight == none or line.number in highlight { numbered } else { faded(numbered) }
}

#let code-file(filename, lang, icon, highlight: none) = block(width: 100%, {
  set text(font-size.small)
  set par(leading: 0.5em)
  show raw.line: line => numbered-line(line, highlight)
  code-panel(
    code-icon(icon),
    raw(read("code/" + filename), lang: lang, block: true),
  )
})

= Intro and Menti

= Different schools, same goal

== Statistical modelling in a nutshell

All statistical frameworks use data $y$ to learn about parameters $theta$:

1. Observe $y$
2. Estimate $theta$

#pause

#v(1em)

Frequentist statistics treats this as an *optimisation problem*.

Bayesian statistics uses *probability calculus*.

#pause

#v(1em)

Bayesian models are generative; going from $theta$ to $y$ is intuitive, too:

1. Assume $theta$
2. Draw $y$

= Why Bayes

== Uncertainty all the way

Uncertainty of parameters is captured in probability distributions.

#grid(
  columns: (1fr, auto, 1fr),
  align: horizon,
  column-gutter: 0.5em,
  image("img/exposure_response.svg"), text(font-size.large)[$arrow.r y_"new" arrow.r$], image("img/burden.svg"),
)

== Fit challenging data

Prior distributions can stabilise models that would otherwise break.

#pause

#code-file("singular_fit.R", "r", "r")

Sometimes our data alone can't identify the model we want to fit.

#pause

But priors are often hotly debated! What are your thoughts?

== Bring your own model

You're allowed to write custom models.#source-note("1")[(but don't have to thanks to packages like `brms`)]

The book encourages this because it's educational.

I also found it liberating and fun!

= How Bayes

== Bayesian inference

#link("http://localhost:1234/")[#big-formula()[
  $
                                                             p(theta | "data") & prop p("data" | theta) && times p(theta) \
    #text(fill: luma(170))[$"posterior" & prop "likelihood" && times "prior"$]
  $
]]



== Probabilistic programming

Probabilistic programming languages allow you to "spell out" the math:
#grid(
  columns: (1fr, 1fr),
  align: horizon,
  column-gutter: 1em,
  $
      y_i & tilde.op "Normal"(mu_i, sigma) \
     mu_i & = alpha + beta x_i \
    alpha & tilde.op "Normal"(0, 10) \
     beta & tilde.op "Normal"(0, 10) \
    sigma & tilde.op "Exponential"(1)
  $,
  code-file("linear_regression.R", "r", "r", highlight: range(5, 10)),
)

= What Bayes

= Appendix

== Stan

#code-file("linear_regression.stan", "stan", "stan")

== PyMC

#code-file("linear_regression.py", "python", "python")

== Turing.jl

#code-file("linear_regression.jl", "julia", "julia")
