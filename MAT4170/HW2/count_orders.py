
from math import comb, factorial, lcm


def partitions(n: int):
    if (n == 0): 
        return []

    out = [[n]]
    for i in range(1, n):
        x = [[i] + y for y in partitions(n-i)]
        out.extend(x)

    return out


def filter_for_dups(p):
    out = set()
    for px in p:
        pxs = sorted(px)
        out.add(tuple(pxs))
    return out

def filter_for_lcm(p, val):
    return list(filter(lambda x: lcm(*x) == val, p)) 

p_8 = partitions(8) # a lot of stuff
p_8_filterd = filter_for_dups(p_8)
p_8_filterd = filter_for_lcm(p_8_filterd, 15)
print(p_8_filterd) # [(3, 5)]

ways = comb(8, 3) * factorial(2) * factorial(4)
print(ways) # 2688