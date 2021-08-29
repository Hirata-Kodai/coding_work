class MyClass:
    def __init__(self, first_name, last_name):
        "my class"
        self.first_name = first_name
        self.last_name = last_name

    def declare_fullname(self):
        '''名前を宣言する'''
        print(f'私の名前は{self.first_name + self.last_name}です。')

me = MyClass('平田', '航大')
me.declare_fullname()
