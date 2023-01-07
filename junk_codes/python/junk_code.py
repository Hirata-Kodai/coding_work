import numpy as np
import copy
import random

a = [[1], [2]]
b = [[3], [4]]
x = np.array([a, b])
x_copy = copy.copy(x)
x_deepcopy = copy.deepcopy(x)
print(f'x: {id(x)}')
print(f'x_copy: {id(x_copy)}')
print(f'x_deepcppy: {id(x_deepcopy)}')

print('component of x')
for v in x:
    v[0] = random.randint(1, 10)
    v[1] = random.randint(1, 10)
print(x)
print(x_copy)
print(x_deepcopy)
