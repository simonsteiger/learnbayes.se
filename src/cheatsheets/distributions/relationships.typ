#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import "theme.typ": body-font, ink, site, title-font

#set document(title: "How probability distributions are related")
#set page(width: auto, height: auto, margin: 1cm)
#set text(font: body-font, size: 8.4pt, lang: "en", region: "gb")

// A tone colours a node: a stroke shade and a fill tint. The shade has at
// least 3:1 contrast against white and, except for the Dirichlet (drawn in
// tints of the Beta shade), is the plot colour in distributions.jl.
#let tone(shade, fill) = (shade: shade, fill: fill)

#let two-outcomes = tone(rgb("#C07900"), site.advanced-lighter)
#let k-outcomes = tone(rgb("#875500"), site.advanced-light)
#let counts = tone(rgb("#B84145"), site.expert-lighter)
#let waiting-discrete = tone(rgb("#009E73"), site.beginner-lighter)
#let waiting-continuous = tone(rgb("#057154"), site.beginner-light)
#let measurements = tone(site.gray-500, site.gray-100)
#let probability-scalar = tone(site.accent-500, site.accent-50)
#let probability-vector = tone(site.accent-700, site.accent-100)

#let dist-node(pos, name, tone) = node(
  pos,
  text(size: 8.4pt, weight: "medium", fill: ink, name),
  fill: tone.fill,
  stroke: 0.8pt + tone.shade,
  name: label(lower(name).replace(" ", "-")),
)

#let edge-ink = site.gray-500
#let built-from(from, to, body, ..args) = edge(
  from,
  to,
  "-|>",
  text(fill: edge-ink, body),
  stroke: 0.7pt + edge-ink,
  ..args,
)
#let prior-for(from, to, body, ..args) = edge(
  from,
  to,
  "--|>",
  text(fill: edge-ink, body),
  stroke: 0.7pt + edge-ink,
  ..args,
)

#let relationships = diagram(
  spacing: (13mm, 10mm),
  node-inset: 5pt,
  node-corner-radius: 3pt,
  label-size: 7.6pt,
  dist-node((0, 0), "Beta", probability-scalar),
  dist-node((0, 1.4), "Dirichlet", probability-vector),
  dist-node((1.3, 0), "Bernoulli", two-outcomes),
  dist-node((2.6, 0), "Binomial", two-outcomes),
  dist-node((4, 0), "Beta-binomial", two-outcomes),
  dist-node((1.3, 1.4), "Categorical", k-outcomes),
  dist-node((2.6, 1.4), "Multinomial", k-outcomes),
  dist-node((5, 0.7), "Normal", measurements),
  dist-node((5, 1.4), "Student-t", measurements),
  dist-node((6, 0), "Poisson", counts),
  dist-node((8.2, 0), "Negative binomial", counts),
  dist-node((6, 1.4), "Gamma", waiting-continuous),
  dist-node((7.1, 1.4), "Exponential", waiting-continuous),
  dist-node((8.2, 1.4), "Geometric", waiting-discrete),

  built-from(<bernoulli>, <binomial>, [sum of $n$]),
  built-from(<binomial>, <beta-binomial>, [$p tilde "Beta"$]),
  built-from(<categorical>, <multinomial>, [counts of $n$ draws], label-side: left),
  built-from(<bernoulli>, <categorical>, [$K$ outcomes], label-side: left),
  built-from(<binomial>, <multinomial>, [$K$ outcomes], label-side: left),
  built-from(<beta>, <dirichlet>, [$K$ categories], label-side: left),
  built-from(<binomial>, <normal>, [large $n$], label-side: left),
  built-from(<poisson>, <normal>, [large $lambda$], label-side: right),
  built-from(<student-t>, <normal>, [large $nu$], label-side: left),
  built-from(<poisson>, <negative-binomial>, [$lambda tilde "Gamma"$]),
  built-from(<geometric>, <negative-binomial>, [sum of $r$: failures \ before $r$-th success \ (in the $(r, p)$ form)], label-side: left),
  edge(<exponential>, <geometric>, "<|-|>", text(fill: edge-ink)[continuous / discrete \ waiting time], stroke: 0.7pt + edge-ink, label-side: right),
  built-from(<exponential>, <gamma>, [sum of $alpha$ \ (whole-number $alpha$)], label-side: left),

  prior-for(<beta>, <bernoulli>, [$p$], label-side: right),
  prior-for(<beta>, <binomial>, [$p$], bend: 35deg),
  prior-for(<dirichlet>, <categorical>, [$theta$], label-side: left),
  prior-for(<dirichlet>, <multinomial>, [$theta$], bend: -35deg),
  prior-for(<gamma>, <poisson>, [$lambda$], label-side: right),
)

#let legend-arrow(dashed) = box(baseline: -0.3em, line(
  length: 1.2cm,
  stroke: (paint: edge-ink, thickness: 0.7pt, dash: if dashed { "dashed" } else { none }),
))

#grid(
  columns: auto,
  row-gutter: 6pt,
  grid(
    columns: (auto, auto),
    column-gutter: 2em,
    text(font: title-font, size: 10pt, weight: "bold", fill: ink)[How the distributions are related],
    align(right, text(fill: ink, size: 7.8pt)[
      #legend-arrow(false) one distribution is built from or approaches another
      #h(1.2em)
      #legend-arrow(true) prior for the parameter on the arrow
    ]),
  ),
  align(center, relationships),
)
