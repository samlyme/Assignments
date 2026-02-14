
from math import comb, factorial, lcm, prod


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

p_19 = partitions(19) # a lot of stuff
p_19_filterd = filter_for_dups(p_19)
p_19_filterd = filter_for_lcm(p_19_filterd, 210)
print(p_19_filterd) # [(2, 2, 3, 5, 7), (1, 1, 2, 3, 5, 7), (1, 5, 6, 7)]

def multinomial_coeff(boxes):
    n = sum(boxes)

    dups = 1
    seen = set()
    for i in boxes:
        if i in seen:
            dups += 1
        seen.add(i)

    return factorial(n) / (prod(factorial(n_i) for n_i in boxes) * factorial(dups))

ways = 0
for boxes in p_19_filterd:
    ways += multinomial_coeff(boxes) * prod(factorial(n_i-1) for n_i in boxes)
# print(factorial(19)) # for debugging
print(int(ways)) # 1013709170073600