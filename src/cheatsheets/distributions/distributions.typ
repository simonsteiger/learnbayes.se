#import "theme.typ": tab20b
#import "layout.typ": category, cheatsheet, entry, sheet

#show: cheatsheet

#let outcomes = category(tab20b.ochre.dark, tab20b.ochre.background)
#let counts = category(tab20b.red.dark, tab20b.red.background)
#let waiting = category(tab20b.olive.dark, tab20b.olive.background)
#let measurements = category(tab20b.indigo.dark, tab20b.indigo.background)
#let probabilities = category(tab20b.magenta.dark, tab20b.magenta.background)

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

#let common-title = [Common probability distributions]
#let common-categories = (
  ("Measurements", measurements, (normal, student-t)),
  ("Counts", counts, (poisson, negative-binomial)),
  ("Probabilities", probabilities, (beta-entry, dirichlet)),
  ("Waiting times", waiting, (geometric, exponential, gamma)),
  ("Outcomes & choices", outcomes, (bernoulli, binomial, categorical, multinomial)),
)

#sheet(common-title, common-categories)
