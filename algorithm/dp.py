# https://leetcode.com/problems/climbing-stairs/submissions/
import time

def climbStairs_recursive(n: int):
    '''
    Recursive version.
    You are climbing a staircase. It takes n steps to reach the top.
    Each time you can either climb 1 or 2 steps. In how many distinct ways can you climb to the top?
    pram: n: nums of top: int
    return res: nums of ways: int
    '''
    if n == 1:
        return 1
    elif n == 2:
        return 2
    else:
        return climbStairs_recursive(n-1) + climbStairs_recursive(n-2)

def climbStairs_DP(n: int):
    '''
    Dynamic Programming version.
    You are climbing a staircase. It takes n steps to reach the top.
    Each time you can either climb 1 or 2 steps. In how many distinct ways can you climb to the top?
    pram: n: nums of top: int
    return res: nums of ways: int
    '''
    dp = [1,1]
    for i in range(2, n+1):
        dp.append(dp[i-1]+dp[i-2])  # 今回は2段しか登れないため、i-2 まで
    return dp[-1]


if __name__ == '__main__':
    t1 = time.time()
    print(climbStairs_recursive(34))
    t2 = time.time()
    print(f'Recursive: {t2-t1}')
    
    t1 = time.time()
    print(climbStairs_DP(34))
    t2 = time.time()
    print(f'DP: {t2 - t1}')
