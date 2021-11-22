from typing import Optional
from ListNode import ListNode


def deleteDuplicates(head: Optional[ListNode]) -> Optional[ListNode]:
    if not head:
        return head
    now_node = head
    next_node = head.next
    while next_node:
        while now_node.val == next_node.val:
            now_node.next = next_node.next
            if not next_node.next:
                return head
            next_node = next_node.next
        now_node = next_node
        next_node = next_node.next
    return head
