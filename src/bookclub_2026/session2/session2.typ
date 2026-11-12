#import "@preview/touying:0.6.1": *
#import "../template/ki.typ": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import "@preview/tiaoma:0.3.0": *

#show: ki-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: "Learn Bayes book club",
    subtitle: "Session 2",
    date: "2026-11-10",
  ),
)

#title-slide()

= Video lecture A02

== How did it go?

- Did you watch the video lectures?

#pause

- How did you like them? Any comments?

#pause

- Did you have a look at the exercise?

== Prior, likelihood, posterior

*Prior* \
What we know before

*Likelihood* \
What the data say

*Posterior* \
What we know afterwards

== Workflow: dementia prevalence

#let workflow-nodes = (
  ((0, 0.5), [Generative \ model]),
  ((0, 1.5), [Estimand]),
  ((1, 1), [Statistical \ model]),
  ((2, 0), [Data]),
  ((2, 1), [Estimate]),
  ((3, 0), [#emoji.sparkles Answers #emoji.sparkles]),
)

#let workflow-edges = (
  ((0, 0.5), (1, 1), -5deg),
  ((0, 1.5), (1, 1), 20deg),
  ((1, 1), (2, 1), -10deg),
  ((2, 0), (2, 1), 15deg),
  ((2, 1), (3, 0), -35deg),
)

#let workflow-diagram = diagram(
  spacing: (2em, 4em),
  edge-stroke: 1pt,
  ..workflow-nodes.map(((position, label)) => node(position, label)),
  ..workflow-edges.map(((source, target, bend)) => edge(source, target, "-|>", bend: bend)),
)

Let's fill out the workflow for a study that estimates dementia prevalence.

#v(1fr)

#align(center + horizon, workflow-diagram)

#v(1fr)

#h(1fr) Time: 10 minutes

== Exercise A02

Two small hints:

+ The posterior distribution is a Beta distribution.

+ If we have no data at all, the Beta distribution is

$
  "Beta"(alpha = 1, beta = 1)
$

#v(1fr)
#h(1fr) Time: until 17:00

== Solution A02

#code-box("session2/a02.R")

= Video lecture A03

== Workflow: height and weight

#v(1fr)

#align(center + horizon, workflow-diagram)

#v(1fr)
#h(1fr) Time: 10 minutes

== Exercise A03

#code-box("session2/a03.R")

#v(1fr)
#place(bottom + right, dx: 2em, dy: 2.25em, barcode("https://github.com/rmcelreath/stat_rethinking_2026/blob/main/homework/homework_A03.pdf", "QRCode", options: (scale: 1.5)))
