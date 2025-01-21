library(ggplot2)

df <- data.frame(theta = samples)

ggplot(df, aes(x = theta)) +
  geom_histogram(aes(y = ..density..), bins = 30, fill = "skyblue", color = "black") +
  stat_function(
    fun = dbeta, args = list(
      shape1 = alpha + sum(y),
      shape2 = beta + sum(y == 0)
    ),
    color = "red", size = 1
  ) +
  stat_function(
    fun = dbeta, args = list(shape1 = alpha, shape2 = beta),
    color = "green", size = 1
  ) +
  labs(x = "theta", y = "Density", title = "Posterior Distribution of theta") +
  theme_minimal() +
  scale_color_manual(values = c(
    "Posterior" = "skyblue",
    "Analytical Posterior" = "red",
    "Prior" = "green"
  )) +
  guides(color = guide_legend(title = NULL))
