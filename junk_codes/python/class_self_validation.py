class Dog():
    def __init__(self, name):
        self.dog_name = name

    def call(self):
        print(f'{self.dog_name} U^ｪ^U < baubau!')


def main():
    a_dog = Dog('チーズ')
    print(a_dog.dog_name)
    a_dog.call()  # メソッドを呼ぶときには勝手に self が引数として代入される。（引数を省略できる）
    Dog.call(a_dog)  # call() を関数として呼ぶと、self を省略できない
    print(Dog)


if __name__ == '__main__':
    main()
