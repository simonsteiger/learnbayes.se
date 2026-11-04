library(lme4)

# We know `dose` effects vary by clinic
# but some clinics have very little data
fit <- lmer(
  response ~ dose + (dose | clinic),
  data = patients
)
#> boundary (singular) fit: see help('isSingular')
