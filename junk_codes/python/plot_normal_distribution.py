import numpy as np
import matplotlib.pyplot as plt

def gauss_distribution(x, mu=0, sigma=1):
    return np.exp(-((x-mu)**2)/(2*sigma**2))


def main():
    x = np.linspace(-4, 4, 1000)
    y = np.array([gauss_distribution(val) for val in x])
    plt.plot(x, y)
    plt.show()


if __name__ == '__main__':
    main()
