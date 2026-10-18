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

#let code-panel(icon, body) = block(
  width: 100%,
  stroke: 1pt + ki-colors.grey_light.darken(15%),
  radius: 6pt,
  inset: (x: 1em, y: 0.75em),
  {
    place(top + right, icon)
    body
  },
)

#let source-note(number, body) = {
  super(number)
  place(bottom + right, dx: 3em, dy: 1.75em)[
    #set text(0.5em)
    #super(number) #body
  ]
}
