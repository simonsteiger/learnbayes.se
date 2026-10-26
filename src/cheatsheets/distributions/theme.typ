// Fonts and colours shared by the cheatsheets in this directory.

#let body-font = "Avenir Next"
#let title-font = "Iowan Old Style"

// Colours from docs/src/styles/global.css.
#let site = (
  accent-50: rgb("#e6f4f4"),
  accent-100: rgb("#cce9ea"),
  accent-300: rgb("#66bcbf"),
  accent-500: rgb("#009095"),
  accent-700: rgb("#005659"),
  accent-800: rgb("#003a3c"),
  secondary-dark: rgb("#FF876F"),
  gray-100: rgb("#f6f6f6"),
  gray-200: rgb("#eeeeee"),
  gray-500: rgb("#585858"),
  gray-800: rgb("#272727"),
  beginner-light: rgb("#C6ECE2"),
  beginner-lighter: rgb("#E0F5EF"),
  beginner-dark: rgb("#094434"),
  advanced-light: rgb("#FFE3B3"),
  advanced-lighter: rgb("#FFF0D6"),
  advanced-dark: rgb("#4D3000"),
  expert-light: rgb("#EBC7C7"),
  expert-lighter: rgb("#F4E1E1"),
  expert-dark: rgb("#381414"),
)

// Makie's tab20b palette has five hues with four shades each. `dark` and `mid`
// are its first and second shades; `background` is its fourth shade mixed with
// 70% white, as computed by `lighten` in plotting.jl.
#let tab20b = (
  indigo: (dark: rgb("#393B79"), mid: rgb("#5254A3"), background: rgb("#E1E2F5")),
  olive: (dark: rgb("#637939"), mid: rgb("#8CA252"), background: rgb("#F0F4E1")),
  ochre: (dark: rgb("#8C6D31"), mid: rgb("#BD9E39"), background: rgb("#F8EFDF")),
  red: (dark: rgb("#843C39"), mid: rgb("#AD494A"), background: rgb("#F8E0E1")),
  magenta: (dark: rgb("#7B4173"), mid: rgb("#A55194"), background: rgb("#F5E2F3")),
)

// Hues from Makie's tab20c palette, with shades chosen as for `tab20b`.
#let tab20c = (
  blue: (dark: rgb("#3182BD"), mid: rgb("#6BAED6"), background: rgb("#EEF4FA")),
  orange: (dark: rgb("#E6550D"), mid: rgb("#FD8D3C"), background: rgb("#FEF1E3")),
)

#let ink = site.gray-800
