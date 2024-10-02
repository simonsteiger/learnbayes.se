library(brms)

n <- 30
x <- rnorm(n, mean = 0, sd = 1)
p <- ifelse(x > 1, 0.2, 0.8)
y <- sapply(p, function(p) sample(c(0, 1), 1, prob = c(1 - p, p)))

data <- data.frame(x = x, y = y)

fit <- brm(y ~ x, family = bernoulli(link = "logit"), data = data)
fit
