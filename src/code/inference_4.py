import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np

sns.histplot(samples, stat="density", label="Posterior", kde=False, color='skyblue', bins=30)
theta = np.linspace(0, 1, 100)

plt.plot(theta, analytic_posterior.pdf(theta), label="Analytic Posterior", linewidth=2)

plt.plot(theta, prior.pdf(theta), label="Prior", linewidth=2)

plt.xlabel("Theta")
plt.ylabel("Density")
plt.title("Posterior Distribution of Theta")

plt.legend()

plt.show()
