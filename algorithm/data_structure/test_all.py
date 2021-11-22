from ListNode import make_LinkedList_from_num_list
from deleteDuplicates import deleteDuplicates


def test_duplicate():
    test_case = make_LinkedList_from_num_list([1, 1, 1, 2, 3, 4, 5, 5])
    res = deleteDuplicates(test_case)
    head = res
    submit = []
    while head.next:
        submit.append(head.val)
        head = head.next
    assert submit == [1, 2, 3, 4, 5]
