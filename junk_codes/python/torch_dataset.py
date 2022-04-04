from torch.utils.data import Dataset
from torch.utils.data import DataLoader
from torch import LongTensor
import torch
import random
import numpy as np


class SampleDataset(Dataset):
    def __init__(self, n: int):
        # data load
        self.labeling_list = []
        for i in range(n):
            self.labeling_list.append(0)
            self.labeling_list.append(1)
        random.shuffle(self.labeling_list)

    def __len__(self):
        return len(self.labeling_list)

    def __getitem__(self, idx):
        return LongTensor([self.labeling_list[idx]])


def main():
    dataset = SampleDataset(5)
    dataloader = DataLoader(dataset=dataset, batch_size=2)
    for v in dataloader:
        print(v[1].item())


if __name__ == '__main__':
    main()
