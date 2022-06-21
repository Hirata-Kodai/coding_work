from dataclasses import dataclass


@dataclass
class MyDataClass:
    id: int
    name: str
    sex: str


class MyClass:
    def __init__(self, first_name, last_name):
        "my class"
        self.first_name = first_name
        self.last_name = last_name

    def declare_fullname(self):
        '''名前を宣言する'''
        print(f'私の名前は{self.first_name + self.last_name}です。')

    def greeting(self):
        print('こんにちは')


def main():
    me = MyClass('航大', '平田')
    me.greeting()
    me.declare_fullname()
    data = MyDataClass(1, 'Hirata Kodai', 'Male')
    print(data.id)


if __name__ == '__main__':
    main()
