---
title: Introduction to Gaussian Processes
description: An introduction to GPs, ending with PPL implementations.
level: expert
tags:
  - Introduction
  - Nonparametric
links:
  julia: /julia/gps.html
---

We'll explores how data can be modelled non-parametrically by placing probability distributions over functions. Over – ... _functions_?! That still sounds wild to me even after writing this notebook.

In this notebook, I will walk through the math behind Gaussian Processes (GPs) and how they enable us to tackle this seemingly impossibly complex problem.

While working on this, I have heavily relied on what I learned from [Mattias Villani](mattiasvillani.com)'s [Advanced Bayesian Learning course](https://github.com/mattiasvillani/AdvBayesLearnCourse) and the book [Gaussian Processes for Machine Learning](https://gaussianprocess.org/gpml/chapters/RW.pdf).

The data analysed in the examples towards the end of this notebook is [Lidar](https://en.wikipedia.org/wiki/Lidar) data.
