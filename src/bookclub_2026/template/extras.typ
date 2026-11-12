#let ki-colors = (
  plum: rgb("870052"),
  plum_light: rgb(237, 219, 228),
  plum_dark: rgb("4F0433").lighten(10%),
  orange: rgb("FF876F"),
  orange_light: rgb("FEEEEB"),
  orange_dark: rgb("B84145"),
  blue: rgb("4DB5BC").darken(20%),
  blue_light: rgb("EDF4F4"),
  blue_dark: rgb("002C34"),
  grey: rgb("666666"),
  grey_light: rgb("F1F1F1"),
  grey_dark: rgb("000000"),
  green: rgb("54B986"),
  green_light: rgb("C7ECDC"),
  green_dark: rgb("094334"),
  yellow: rgb("FFC66D"),
  yellow_light: rgb("#FFF1DB"),
  yellow_dark: rgb("F59A00"),
)

#let font-size = (
  body: 20pt,
  smaller: 12pt,
  small: 16pt,
  large: 30pt,
  xl: 40pt,
)

#let code-panel-border = 1pt + ki-colors.grey_light.darken(15%)

#let code-panel(filename, body) = block(
  width: 100%,
  stroke: code-panel-border,
  radius: 6pt,
  clip: true,
  stack(
    if filename != none {
      block(
        width: 100%,
        fill: ki-colors.grey_light,
        stroke: (bottom: code-panel-border),
        inset: (x: 1em, y: 0.5em),
        text(fill: ki-colors.grey, raw(filename)),
      )
    },
    block(width: 100%, inset: (x: 1em, y: 0.75em), body),
  ),
)

// Transparency keeps the hue of each syntax-highlighted token.
#let faded(body) = {
  show text: it => context {
    set text(fill: text.fill.transparentize(70%))
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

// `path` is relative to the project root (by default the folder of the compiled
// file): `read` resolves relative paths against this file, not the caller's.
// Trailing whitespace, including blank last lines, is dropped.
// `lang` defaults to the file extension.
// `filename: false` omits the header row showing the file's name.
// Lines whose number is not in `highlight` are faded; `none` shows all lines.
#let code-box(path, lang: auto, filename: true, highlight: none) = block(width: 100%, {
  let root-relative-path = if path.starts-with("/") { path } else { "/" + path }
  let basename = path.split("/").last()
  let lang = if lang == auto { basename.split(".").last() } else { lang }
  set text(font-size.small)
  set par(leading: 0.5em)
  code-panel(
    if filename { basename },
    {
      show raw.line: line => numbered-line(line, highlight)
      raw(read(root-relative-path).trim(at: end), lang: lang, block: true)
    },
  )
})

#let source-note(number, body) = {
  super(number)
  place(bottom + right, dx: 3em, dy: 1.75em)[
    #set text(0.5em)
    #super(number) #body
  ]
}
