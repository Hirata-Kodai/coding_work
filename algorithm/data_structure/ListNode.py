class ListNode:
    def __init__(self, val=0, next=None):
        self.val = val
        self.next = next


def make_LinkedList_from_num_list(num_list):
    head = now = ListNode()
    for val in num_list:
        now.val = val
        now.next = ListNode()
        now = now.next
    return head
