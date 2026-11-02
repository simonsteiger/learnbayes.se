---
title: Introduction to Hidden Markov models
description: Learn about a powerful technique to model longitudinal data.
level: advanced
tags:
  - Introduction
  - Multistate
  - Time series
links:
  julia: /julia/hmm.html
---

This notebook explores how longitudinal data can be modelled as a sequence of (noisy) observations emitted from latent states.

The content covers simulating hidden markov models using [HiddenMarkovModels.jl](https://juliastats.org/HiddenMarkovModels.jl/stable/), and inference on transition and emission probabilities via Turing.

It's also a great showcase of julia's and Turing's extensibility: we can reuse all the logdensity calculations provided by HiddenMarkovModels.jl inside our Turing model (and once I get around to updating this to FlexiChains instead of MCMCChains, we'll even be able to return HMM objects directly)!
