# Basic distributions

## Normal

- support all reals
- two parameters mean and sd

## Exponential

- support positive reals
- distribution of a rate at which an event occurs in continuous time
- rate lambda determines probability of event at ... infinitely small step (?)

## Geometric

- support positive integers
- discrete version of exponential
- single parameter p gives probability of event at next step

## Bernoulli

- support {0, 1} (boolean)
- binary outcomes
- single parameter (probability of 1)

## Binomial

- related to Bernoulli (repeat same Bernoulli and count)
- parameters n, p
- support positive integers with upper bound n

## Beta-binomial

- support positive integers with upper bound n
- overdispersed generalisation of Binomial
- different ways to parameterise (mu, phi shown here? pros / cons?)

## Poisson

- support positive integers
- single parameter (rate) lambda, large mean entails large dispersion

## Negative binomial

- support positive integers
- parameters for rate and overdispersion (?)
- overdispersed generalisation of Poisson (?)

## Gamma

- support positive reals
- rate and shape parameters (?)

## Categorical

- distribution of probability to observe category k out of K
- support integers 1:K
- parameterised with simplex length K

## Multinomial

- related to Categorical (repeat same Categorical and count)
- support positive integers for each entry of length K vector

## Beta

- support [0, 1]
- used to parameterise Bernoulli, Binomial, Beta-binomial

## Dirichlet

- distribution over simplices (vector that sums to 1)
- multidimensional generalisation of Beta
