#import "theme.typ": body-font, ink, tab20b, title-font

#let body-size = 11pt
#let name-size = 15pt
#let category-title-size = 20pt
#let sheet-title-size = 27pt

#set page(paper: "a3", margin: (x: 0pt, y: 1cm))
#set text(font: body-font, size: body-size, lang: "en", region: "gb")
#set par(justify: false, leading: 0.7em)

#let plot-height = 12mm

// A category has a title colour and a box background. The background is also
// the plot background in distributions.jl.
#let category(colour, background) = (colour: colour, background: background)

#let outcomes = category(tab20b.ochre.dark, tab20b.ochre.background)
#let counts = category(tab20b.red.dark, tab20b.red.background)
#let waiting = category(tab20b.olive.dark, tab20b.olive.background)
#let measurements = category(tab20b.indigo.dark, tab20b.indigo.background)
#let probabilities = category(tab20b.magenta.dark, tab20b.magenta.background)

// Every category grid shares these columns. Spacing comes from cell insets and
// spacer rows rather than gutters. The grid spans only the box's text width, so
// row rules end where the text ends. The name column is as wide as the widest
// single word of a name, so names only break between words and the plot sits
// midway between that word and the parameters. The Use column is wider than the
// Meaning column by `use-extra-width`.
#let widest-name-word = "Multinomial"
#let name-text(name) = text(font: title-font, size: name-size, weight: "bold", fill: ink, name)
#let plot-width = 30mm
#let symbol-width = 6mm
#let use-extra-width = 6mm
#let entry-columns(name-width, grid-width) = {
  let meaning-width = (grid-width - name-width - plot-width - symbol-width - use-extra-width) / 2
  (name-width, plot-width, symbol-width, meaning-width, 1fr)
}
#let entry-count = entry-columns(0pt, 0pt).len()
#let cell-padding = 4pt
#let row-padding = 6pt
#let box-padding = 10pt
// The gap between distributions in a box, as a share of the gap between boxes.
#let entry-gap-ratio = 0.5
#let parameter-column = 2
#let use-column = 4
// The parameter rules run up to the use column, so the use text is set further
// in to keep them clear of it.
#let use-indent = 3 * cell-padding
#let entry-inset(x, y) = (
  left: if x == 0 { 0pt } else if x == use-column { use-indent } else { cell-padding },
  right: if x == entry-count - 1 { 0pt } else { cell-padding },
  y: row-padding,
)
// The parameter list and the use text sit on the bottom edge of their row, so
// both rest on the rule that borders the row.
#let entry-align(x, y) = if x in (parameter-column, use-column) { bottom + left } else if x == 1 {
  horizon + center
} else { horizon + left }
#let entry-grid(..cells) = layout(available => grid(
  columns: entry-columns(measure(name-text(widest-name-word)).width + cell-padding, available.width),
  inset: entry-inset,
  align: entry-align,
  ..cells,
))

#let plot(name) = image("img/" + name + ".svg", height: plot-height)

#let ruled-line = (paint: ink.transparentize(80%), thickness: 0.5pt, dash: (array: (6pt, 3pt)))

// One line per parameter, separated by dashed rules; the last line rests on
// the rule that borders the entry's row. The symbol sits in
// a box as wide as the Parameter column and wrapped explanation lines hang at
// the same indent, so explanations line up with the Meaning column and share a
// baseline with their symbol.
#let parameter-list(rows) = {
  let parameter-line((symbol, meaning)) = par(hanging-indent: symbol-width, box(width: symbol-width, symbol) + meaning)
  grid(
    columns: 1fr,
    inset: (left: 0pt, right: cell-padding, y: row-padding),
    ..rows.map(parameter-line).intersperse(grid.hline(stroke: ruled-line)),
  )
}

// An entry is one row of a category grid: its parameter list spans the
// Parameter and Meaning columns, and a dashed rule borders the whole row. The
// parameter list's rules run to the right edge of the Meaning column, which the
// cell's zero right inset allows. `alternative` describes another
// parameterisation and is not shown on the sheet.
#let entry(
  name,
  plot-name,
  rows: (),
  use: none,
  alternative: none,
) = {
  assert(rows.len() > 0, message: name + " needs at least one parameter row")
  (
    name-text(name),
    plot(plot-name),
    grid.cell(colspan: 2, inset: (left: cell-padding, right: 0pt, y: 0pt), parameter-list(rows)),
    use,
    grid.hline(stroke: ruled-line),
  )
}

#let spacer(height) = grid.cell(colspan: entry-count, inset: 0pt, v(height))

// The title gets the same row padding as a distribution, so the gap below the
// title matches the gap between distributions.
#let group(title, category, entry-gap, ..entries) = block(
  fill: category.background,
  inset: box-padding,
  entry-grid(
    grid.cell(
      colspan: entry-count,
      inset: (x: 0pt, top: 0pt, bottom: row-padding),
      text(font: title-font, size: category-title-size, weight: "bold", fill: category.colour, title),
    ),
    spacer(entry-gap),
    ..entries.pos().intersperse((spacer(entry-gap),)).flatten(),
  ),
)

#let bernoulli = entry(
  "Bernoulli",
  "bernoulli",
  rows: (
    ($p$, [probability of a 1 ("success")]),
  ),
  use: [0 or 1. A single binary outcome, e.g. coin lands heads. Logistic regression. $p arrow$ Beta prior.],
)

#let binomial = entry(
  "Binomial",
  "binomial",
  rows: (
    ($n$, [number of trials]),
    ($p$, [probability of success per trial]),
  ),
  use: [Integers 0 to $n$. Successes in $n$ with the same $p$, e.g. coin throws. Logistic regression. $p arrow$ Beta prior.],
)

#let categorical = entry(
  "Categorical",
  "categorical",
  rows: (
    ($theta$, [simplex of length $K$; $theta_k$ is the probability of category $k$]),
  ),
  use: [Integers 1 to $K$. Choose one of $K$, e.g. your favourite color. Multinomial regression. $theta arrow$ Dirichlet prior.],
)

#let multinomial = entry(
  "Multinomial",
  "multinomial",
  rows: (
    ($n$, [number of draws]),
    ($theta$, [simplex of length $K$; see Categorical]),
  ),
  use: [$K$ counts summing to $n$. Choose $n$ times out of $1$ to $K$ . \ Multinomial regression, durrr. $theta arrow$ Dirichlet prior.],
)

#let poisson = entry(
  "Poisson",
  "poisson",
  rows: (
    ($lambda$, [rate: both the mean and the variance]),
  ),
  use: [Non-negative integers. Counts of events occuring at a fixed rate. Poisson regression, heh. $lambda arrow$ Gamma prior.],
)

#let negative-binomial = entry(
  "Negative binomial",
  "negbinomial",
  rows: (
    ($mu$, [mean]),
    ($phi$, [dispersion: variance is $mu + mu^2 \/ phi$ \ smaller $phi$ $arrow$ more overdispersion]),
  ),
  use: [Non-negative integers. Robust alternative to Poisson when mean and variance need to be decoupled.],
)

#let geometric = entry(
  "Geometric",
  "geometric",
  rows: (
    ($p$, [probability of success in each trial; mean is $(1 - p) \/ p$]),
  ),
  use: [Non-negative integers. The number of failures before the first success. Survival models. $p arrow$ Beta prior.],
  alternative: [Some texts count trials instead: support ${1, 2, dots}$, mean $1 \/ p$.],
)

#let exponential = entry(
  "Exponential",
  "exponential",
  rows: (
    ($lambda$, [rate: events per unit of time; mean is $1 \/ lambda$]),
  ),
  use: [Positive reals. Waiting time until the next event at a constant rate. Survival models. $lambda arrow$ Gamma prior.],
)

#let gamma = entry(
  "Gamma",
  "gamma",
  rows: (
    ($alpha$, [shape]),
    ($beta$, [rate; mean is $alpha \/ beta$, variance is $alpha \/ beta^2$]),
  ),
  use: [Positive reals. Waiting time for $alpha$ events, e.g. three Covid infections; good choice as prior for rates.],
  alternative: [*Also written* Gamma$(k, theta)$: shape $k = alpha$, scale $theta = 1 \/ beta$, mean $k theta$.],
)

#let normal = entry(
  "Normal",
  "normal",
  rows: (
    ($mu$, [mean]),
    ($sigma$, [standard deviation]),
  ),
  use: [All real numbers. Much distribution, very symmetry, wow. Pick me, c'mon just do it. Ah, linear regression.],
)

#let student-t = entry(
  "Student-t",
  "studentt",
  rows: (
    ($nu$, [degrees of freedom, smaller $nu$ $arrow$ heavier tails]),
    ($mu$, [mean, if $nu > 1$]),
    ($sigma$, [scale; variance is $sigma^2 nu \/ (nu - 2)$ if $nu > 2$]),
  ),
  use: [All real numbers. Robust alternative to Normal. Good choice if many outliers. At $nu > 30$ turns into Normal.],
)

#let beta-entry = entry(
  "Beta",
  "beta",
  rows: (
    ($alpha$, [number of prior successes]),
    ($beta$, [number of prior failures]),
  ),
  use: [Between 0 and 1. Typically a probability, very useful as a prior for Bernoulli and Binomial.],
)

#let dirichlet = entry(
  "Dirichlet",
  "dirichlet",
  rows: (
    ($alpha$, [vector of $K$ concentrations; \ mean of component $k$ is $alpha_k \/ sum_j alpha_j$]),
  ),
  use: [Simplex of length $K$. $K$ probabilities summing to 1; \ a prior for Categorical and Multinomial.],
)

#let footer-size = 8pt
#let footer-ink = ink.transparentize(55%)
#let swatch-size = 3mm

#let footer-text(body) = text(size: footer-size, fill: luma(150), body)

#let swatch(colour) = box(baseline: 15%, rect(width: swatch-size, height: swatch-size, fill: colour))
#let swatch-legend(categories) = (
  categories
    .map(category => swatch(category.background) + h(0.4em) + footer-text(upper(category.background.to-hex())))
    .join(h(1.2em))
)

#let footer(categories) = {
  text(font: title-font, 8pt, luma(150), "Iowan Old Style")
  h(1em)
  text(font: body-font, 8pt, luma(150), "Avenir Next")
  h(1fr)
  swatch-legend(categories)
  h(1fr)
  text(8pt, luma(150), "Something wrong? Email me: simon.steiger@ki.se")
}

#let sheet(box-gap, entry-gap) = {
  let titled-categories = (
    ("Measurements", measurements, (normal, student-t)),
    ("Counts", counts, (poisson, negative-binomial)),
    ("Probabilities", probabilities, (beta-entry, dirichlet)),
    ("Waiting times", waiting, (geometric, exponential, gamma)),
    ("Outcomes & choices", outcomes, (bernoulli, binomial, categorical, multinomial)),
  )
  grid(
    columns: 1fr,
    row-gutter: box-gap,
    text(font: title-font, size: sheet-title-size, weight: "bold", fill: ink)[Common probability distributions],
    ..titled-categories.map(((title, category, entries)) => group(title, category, entry-gap, ..entries)),
    footer(titled-categories.map(((_, category, _)) => category)),
  )
}

// The box gap is chosen so the sheet fills the page height exactly. Sheet
// height is linear in the box gap at a fixed width, so two measurements give
// the gap; the side margins equal the gap and change the width, so the
// calculation is repeated until the gap settles.
#let page-filling-box-gap(available, box-gap) = {
  let width = available.width - 2 * box-gap
  let sheet-height(gap) = measure(sheet(gap, gap * entry-gap-ratio), width: width).height
  let height-without-gaps = sheet-height(0pt)
  let height-per-point = sheet-height(1pt) - height-without-gaps
  let gap = (available.height - height-without-gaps) / height-per-point * 1pt
  assert(gap > 0pt, message: "the sheet is taller than the page even without gaps")
  gap
}

#layout(available => {
  // A small allowance keeps rounding from pushing the sheet onto a second page.
  let fill-area = (width: available.width, height: available.height - 1pt)
  let box-gap = range(4).fold(1cm, (gap, _) => page-filling-box-gap(fill-area, gap))
  pad(x: box-gap, sheet(box-gap, box-gap * entry-gap-ratio))
})
