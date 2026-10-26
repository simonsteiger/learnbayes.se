#import "theme.typ": body-font, ink, title-font

#let body-size = 11pt
#let name-size = 15pt
#let category-title-size = 20pt
#let sheet-title-size = 27pt

#let cheatsheet(body) = {
  set page(paper: "a3", margin: (x: 0pt, y: 1cm))
  set text(font: body-font, size: body-size, lang: "en", region: "gb")
  set par(justify: false, leading: 0.7em)
  body
}

#let plot-height = 12mm

// A category has a title colour and a box background. The background is also
// the plot background in the sheet's plotting script.
#let category(colour, background) = (colour: colour, background: background)

// Every category grid shares these columns. Spacing comes from cell insets and
// spacer rows rather than gutters. The grid spans only the box's text width, so
// row rules end where the text ends. The name column is as wide as the widest
// single word of any name on the sheet, so names only break between words and
// the plot sits midway between that word and the parameters. The Use column is
// wider than the Meaning column by `use-extra-width`.
#let name-text(name, fill: ink) = text(font: title-font, size: name-size, weight: "bold", fill: fill, name)
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
#let entry-grid(name-width, ..cells) = layout(available => grid(
  columns: entry-columns(name-width, available.width),
  inset: entry-inset,
  align: entry-align,
  ..cells,
))

#let plot(name) = image("img/" + name + ".svg", height: plot-height)

#let ruled-line(colour) = (paint: colour.transparentize(80%), thickness: 0.5pt, dash: (array: (6pt, 3pt)))

// One line per parameter, separated by dashed rules; the last line rests on
// the rule that borders the entry's row. The symbol sits in
// a box as wide as the Parameter column and wrapped explanation lines hang at
// the same indent, so explanations line up with the Meaning column and share a
// baseline with their symbol.
#let parameter-list(rows, rule) = {
  let parameter-line((symbol, meaning)) = par(hanging-indent: symbol-width, box(width: symbol-width, symbol) + meaning)
  grid(
    columns: 1fr,
    inset: (left: 0pt, right: cell-padding, y: row-padding),
    ..rows.map(parameter-line).intersperse(grid.hline(stroke: rule)),
  )
}

// `alternative` describes another parameterisation and is not shown on the
// sheet.
#let entry(
  name,
  plot-name,
  rows: (),
  use: none,
  alternative: none,
) = {
  assert(rows.len() > 0, message: name + " needs at least one parameter row")
  (name: name, plot-name: plot-name, rows: rows, use: use)
}

// An entry is one row of a category grid: its parameter list spans the
// Parameter and Meaning columns, and a dashed rule borders the whole row. The
// parameter list's rules run to the right edge of the Meaning column, which the
// cell's zero right inset allows. The name and the rules take the category's
// title colour.
#let entry-cells(entry, category) = {
  let rule = ruled-line(category.colour)
  (
    name-text(entry.name, fill: category.colour),
    plot(entry.plot-name),
    grid.cell(colspan: 2, inset: (left: cell-padding, right: 0pt, y: 0pt), parameter-list(entry.rows, rule)),
    entry.use,
    grid.hline(stroke: rule),
  )
}

#let spacer(height) = grid.cell(colspan: entry-count, inset: 0pt, v(height))

// The title gets the same row padding as a distribution, so the gap below the
// title matches the gap between distributions.
#let group(title, category, name-width, entry-gap, ..entries) = block(
  fill: category.background,
  inset: box-padding,
  entry-grid(
    name-width,
    grid.cell(
      colspan: entry-count,
      inset: (x: 0pt, top: 0pt, bottom: row-padding),
      text(font: title-font, size: category-title-size, weight: "bold", fill: category.colour, title),
    ),
    spacer(entry-gap),
    ..entries
      .pos()
      .map(entry => entry-cells(entry, category))
      .intersperse((spacer(entry-gap),))
      .flatten(),
  ),
)

#let footer-size = 8pt
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

// `titled-categories` holds one `(title, category, entries)` triple per box.
#let sheet-body(title, titled-categories, name-width, box-gap, entry-gap) = grid(
  columns: 1fr,
  row-gutter: box-gap,
  text(font: title-font, size: sheet-title-size, weight: "bold", fill: ink, title),
  ..titled-categories.map(((category-title, category, entries)) => group(
    category-title,
    category,
    name-width,
    entry-gap,
    ..entries,
  )),
  footer(titled-categories.map(((_, category, _)) => category)),
)

#let widest-name-word-width(titled-categories) = (
  titled-categories
    .map(((_, _, entries)) => entries)
    .flatten()
    .map(entry => entry.name.split(" "))
    .flatten()
    .map(word => measure(name-text(word)).width)
    .fold(0pt, calc.max)
)

// The box gap is chosen so the sheet fills the page height exactly. Sheet
// height is linear in the box gap at a fixed width, so two measurements give
// the gap; the side margins equal the gap and change the width, so the
// calculation is repeated until the gap settles.
#let page-filling-box-gap(available, box-gap, body-at-gap) = {
  let width = available.width - 2 * box-gap
  let sheet-height(gap) = measure(body-at-gap(gap), width: width).height
  let height-without-gaps = sheet-height(0pt)
  let height-per-point = sheet-height(1pt) - height-without-gaps
  let gap = (available.height - height-without-gaps) / height-per-point * 1pt
  assert(gap > 0pt, message: "the sheet is taller than the page even without gaps")
  gap
}

#let sheet-at-gap(title, titled-categories) = {
  let name-width = widest-name-word-width(titled-categories) + cell-padding
  box-gap => sheet-body(title, titled-categories, name-width, box-gap, box-gap * entry-gap-ratio)
}

// The box gap at which the sheet with these categories fills `available`.
#let filling-gap(title, titled-categories, available) = {
  let body-at-gap = sheet-at-gap(title, titled-categories)
  // A small allowance keeps rounding from pushing the sheet onto a second page.
  let fill-area = (width: available.width, height: available.height - 1pt)
  range(4).fold(1cm, (gap, _) => page-filling-box-gap(fill-area, gap, body-at-gap))
}

// `gap-from` names the sheet whose page-filling box gap this sheet uses, as a
// `(title, titled-categories)` pair; by default it is this sheet itself.
#let sheet(title, titled-categories, gap-from: auto) = layout(available => {
  let (gap-title, gap-categories) = if gap-from == auto { (title, titled-categories) } else { gap-from }
  let box-gap = filling-gap(gap-title, gap-categories, available)
  pad(x: box-gap, sheet-at-gap(title, titled-categories)(box-gap))
})
