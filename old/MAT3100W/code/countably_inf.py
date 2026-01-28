from collections import deque
from csv import Error
from typing import Callable, Iterator, TypeVar
from itertools import islice, tee

# 2. a.
def f(n: int):
    if n < 0:
        raise Error("n must be a natural number")

    if n % 2 == 0:
        return n // 2
    return - (n + 1) // 2

print("2. a. ")
print([f(n) for n in range(11)])

def g(n: int):
    if n >= 0:
        return 2 * n 
    return -2*n - 1

print("2. b. ")
# 2. b. i.
print([g(n) for n in range(-5, 6)])

# 2. b. ii.
print([f(g(n)) for n in range(-5, 6)])

# 2. b. iii.
print([g(f(n)) for n in range(0, 11)])

#  2. c. 
def N() -> Iterator[int]:
    i = 0 
    while True:
        yield i
        i += 1

def Z() -> Iterator[int]:
    n = N()
    yield next(n)
    for i in n:
        yield i
        yield -i

R = TypeVar("R")
S = TypeVar("S")
type Tree[T] = T | tuple[Tree[T], Tree[T]]
def forward_replay(g: Iterator[R]) -> Iterator[R]:
    seen = []
    for elem in g:
        seen.append(elem)
        yield from seen

def reverse_replay(g: Iterator[R]) -> Iterator[R]:
    seen = []
    for elem in g:
        seen.append(elem)
        yield from reversed(seen)
    
def cartesian(a: Iterator[R], b: Iterator[S]) -> Iterator[tuple[R, S]]:
    f = forward_replay(a)
    r = reverse_replay(b)
    yield from zip(f, r)

def h() -> Iterator[tuple[int, int]]:
    yield from cartesian(N(), N())

print("2. c. ")
print(list(islice(h(), 11)))

print("2. d. ")
def A1() -> Iterator[int]:
    # Fibonacci!
    a, b = 0, 1
    yield a
    yield b

    while True: 
        c = a + b
        a, b = b, c 
        yield c

print("A1: ", list(islice(A1(), 11)))

def A2(s: str) -> Iterator[str]:
    # All finite binary for an alphabet s
    frontier = deque([""])
    while True:
        curr = frontier.popleft()
        yield curr
        for c in s:
            frontier.append(curr + c)

print("A2: ", list(islice(A2("01"), 11)))

def f_prime():
    yield from cartesian(A1(), A2("01"))


print("f_prime: ", list(islice(f_prime(), 11)))

# 2. e.
def set_pow(it: Callable[[], Iterator[R]], pow: int) -> Iterator[Tree[R]]:
    if pow < 1:
        raise Exception("Pow must be >=1")
    
    if pow == 1:
        return it()

    if pow % 2 == 0:
        
        return cartesian(*tee(set_pow(it, pow//2), 2))

    return cartesian(it(), set_pow(it, pow-1))


def b_k(k: int):
    yield from set_pow(N, k)


def flatten_tree(t: Tree[R]) -> R | tuple[R, ...]:
    if not isinstance(t, tuple):
        return t

    def leaves(node: Tree[R]) -> Iterator[R]:
        if isinstance(node, tuple):
            # node is a pair of subtrees
            left, right = node
            yield from leaves(left)
            yield from leaves(right)
        else:
            # node is a leaf
            yield node

    return tuple(leaves(t))
    
def b_k_flat(k: int):
    for val in set_pow(N, k):
        yield flatten_tree(val)

print("b_k: ", list(islice(b_k_flat(4), 3)))
print("b_k_flat: ", list(islice(b_k_flat(4), 11)))

def NxN() -> Iterator:
    yield from set_pow(N, 2)

def ZxZ() -> Iterator:
    yield from set_pow(Z, 2)

def index(it: Iterator, index: int):
    return next(islice(it, index, None))


# for i, x in enumerate(set_pow(N, 3)):
#     print(i, flatten_tree(x))

# p = 5
# it = set_pow(N, p)
# m = 100
# for i in range(m+1):
#     x = next(it)
#     print(flatten_tree(x))