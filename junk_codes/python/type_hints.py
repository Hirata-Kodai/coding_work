from typing import List, Dict, Tuple
import numpy as np


def calc_price_including_tax(price: int, tax: float) -> int:
    return int(price*tax)


def main():
    price: int = 100
    tax: float = 1.1
    print(f'{calc_price_including_tax(price, tax)} 円')
    sample_list: List[int] = [1, 2, 3, 4]
    sample_dict: Dict[str, str] = {'username': 'adcd'}
    sample_tuple: Tuple[str, str] = ('aba', 'hoge')


if __name__ == '__main__':
    main()
