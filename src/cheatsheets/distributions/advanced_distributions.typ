#import "theme.typ": tab20b, tab20c
#import "layout.typ": category, cheatsheet, entry, sheet
#import "distributions.typ": common-categories, common-title

#show: cheatsheet

#let measurements = category(tab20b.indigo.dark, tab20b.indigo.background)
#let waiting = category(tab20b.olive.dark, tab20b.olive.background)
#let outcomes = category(tab20b.ochre.dark, tab20b.ochre.background)
#let scales = category(tab20c.blue.dark, tab20c.blue.background)
#let correlations = category(tab20b.magenta.dark, tab20b.magenta.background)
#let extensions = category(tab20c.orange.dark, tab20c.orange.background)

#let laplace = entry(
  "Laplace",
  "laplace",
  rows: (
    ($mu$, [location: mean and median]),
    ($b$, [scale: average distance of $y$ from $mu$]),
  ),
  use: [All real numbers. Sharper peak and heavier tails than Normal. Regularisation prior (Bayesian LASSO).],
  alternative: [*Also called* Double exponential.],
)

#let cauchy = entry(
  "Cauchy",
  "cauchy",
  rows: (
    ($mu$, [location: median]),
    ($gamma$, [scale; half of the values lie within $mu plus.minus gamma$]),
  ),
  use: [All real numbers. Very heavy tails, no mean. Student-t with $nu=1$. Often truncated at 0 $arrow$ variance prior.],
)

#let log-normal = entry(
  "Log-normal",
  "lognormal",
  rows: (
    ($mu$, [mean of $log y$; median is $e^mu$]),
    ($sigma$, [standard deviation of $log y$]),
  ),
  use: [Positive reals. Skewed positive data with multiplicative effects, e.g. reaction time, income.],
  alternative: [Mean is $e^(mu + sigma^2 \/ 2)$.],
)

#let weibull = entry(
  "Weibull",
  "weibull",
  rows: (
    ($k$, [shape: $k < 1 arrow$ falling risk, $k > 1 arrow$ rising risk]),
    ($lambda$, [scale]),
  ),
  use: [Positive reals. Time to event with risk changing over time. Survival models. Exponential at $k = 1$.],
)

#let ordered-logistic = entry(
  "Ordered\u{a0}logistic",
  "orderedlogistic",
  rows: (
    ($eta$, [mean on the latent scale]),
    ($c$, [$K - 1$ ordered cutpoints between categories]),
  ),
  use: [Integers 1 to $K$. Ordered categories, e.g. Likert ratings. Categories need not be equidistant.],
)

#let inverse-gamma = entry(
  "InvGamma",
  "inversegamma",
  rows: (
    ($alpha$, [shape]),
    ($beta$, [scale; mean is $beta \/ (alpha - 1)$ if $alpha > 1$]),
  ),
  use: [Positive reals. Prior for variances. Disallows values close to zero $arrow$ careful with hierarchical models!],
)

#let multivariate-normal = entry(
  "MvNormal",
  "mvnormal",
  rows: (
    ($mu$, [mean vector, one entry for each of $K$ dimensions]),
    ($Sigma$, [$K times K$ covariance matrix]),
  ),
  use: [Vectors of $K$ reals. Correlated outcomes and correlated parameters. $Sigma$ may involve LKJ prior.],
)

#let lkj = entry(
  "LKJ",
  "lkj",
  rows: (
    ($K$, [number of rows and columns]),
    ($eta$, [$eta = 1$ is uniform; larger $eta arrow$ lower correlations]),
  ),
  use: [$K times K$ correlation matrices $Omega$; prior for correlation in MvNormal. Often better to sample Cholesky factor.],
)

#let mixture = entry(
  "Mixtures",
  "mixture",
  rows: (
    ($p$, [simplex of length $K$; components probabilities]),
    ($d$, [vector of $K$ component distributions]),
  ),
  use: [$K$ processes generate data. Example: mix Poisson + excess zeros (Dirac) $arrow$ zero-inflated Poisson.],
)

#let truncated = entry(
  "Truncation",
  "truncated",
  rows: (
    ($l$, [lower bound]),
    ($u$, [upper bound]),
  ),
  use: [Limits support to $[l, u]$. Good for variance priors. Careful otherwise: this introduces strong assumptions!],
)

#let censored = entry(
  "Censoring",
  "censored",
  rows: (
    ($l$, [lower limit; smaller values are recorded as $l$]),
    ($u$, [upper limit; larger values are recorded as $u$]),
  ),
  use: [Limits which parts of the distribution are observed and can be learned about. Closely related to missing data.],
)

#let gaussian-process = entry(
  "Gaussian\u{a0}process",
  "gaussianprocess",
  rows: (
    ($m$, [mean function, often 0]),
    ($k$, [covariance kernel: correlation of $f(x)$ and $f(x')$]),
  ),
  use: [Prior over functions. Nonparametric. Time and space. Scales poorly at $cal(O)(N^3) arrow$ consider approximations.],
)

#let advanced-title = [Advanced probability distributions]
#let advanced-categories = (
  ("Measurements", measurements, (laplace, cauchy, log-normal)),
  ("Waiting times", waiting, (weibull,)),
  ("Outcomes & choices", outcomes, (ordered-logistic,)),
  ("Scales & variances", scales, (inverse-gamma,)),
  ("Correlated quantities", correlations, (multivariate-normal, lkj)),
  ("Extensions", extensions, (mixture, truncated, censored, gaussian-process)),
)

#sheet(advanced-title, advanced-categories, gap-from: (common-title, common-categories))
