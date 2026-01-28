from functools import cache
from math import ceil


@cache
def a(n: int):
    if n == 0 or n == 1:
        return 0
    
    return 3 * a(n-1) + 3**ceil(n/2) - a(ceil(n/2))

print("a(26) = ", a(26))
# a(26) =  1833980928771