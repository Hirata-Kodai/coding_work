from pathlib import Path


class MyPathObj():
    def __init__(self, path_str: str):
        self.path_str = path_str

    def __truediv__(self, prefix: str):
        return MyPathObj(self.path_str+prefix)

    def __str__(self) -> str:
        return self.path_str


def main():
    p = Path("~/")
    mp = MyPathObj("~/")
    print(p / "test.txt")
    print(mp / "test.txt")


if __name__ == '__main__':
    main()
