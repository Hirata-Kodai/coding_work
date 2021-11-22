import numpy as np


def read_file_input():
    with open('./sample_stdin.txt', 'r') as f:
        first_line = f.readline()
        n = (first_line[0])
        mat = np.array([line.strip().split(' ') for line in f])
        mat = np.array([list(map(int, row)) for row in mat])
        print(mat)


def read_stdin():
    n = int(input())
    mat = np.array([list(map(int, input().split(' '))) for _ in range(n)])
    print(mat)


if __name__ == '__main__':
    read_file_input()
    read_stdin()  # python read_input.py < sample_stdin.txt
