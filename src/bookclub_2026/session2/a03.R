n <- 100
sample_alpha <- # 🙈
sample_beta <- # 🙊

plot(NULL, xlim = c(-3, 3), ylim = c(-3, 3), xlab = "age", ylab = "height")
abline(h = 0, lty = 2)
for (i in 1:n) {
  curve(
    # 🙉,
    from = -3,
    to = 3,
    add = TRUE,
    col = col.alpha("black", 0.2)
  )
}
