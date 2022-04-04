import numpy as np

def main():
    with open('./sample_stdin.txt', 'r') as f:
        first_line = f.readline()
        q = int(first_line[0])
        n = (first_line[1])
        mat = np.array([line.strip().split(' ') for line in f])
        mat = np.array([list(map(int, row)) for row in mat])
        print(mat)
    


if __name__ == '__main__':
    main()
