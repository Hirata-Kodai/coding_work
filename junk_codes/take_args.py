import argparse


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('args1', type=int, help='required')
    ap.add_argument('--args2', type=str, default='default', help='optional')
    ap.add_argument('--haiku', action='store_true')
    args = ap.parse_args()

    print(f'args1:{args.args1}')
    print(f'--args2:{args.args2}')
    print(args.haiku)


if __name__ == '__main__':
    main()
