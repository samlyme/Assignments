from typing import Iterator, TypeVar
from itertools import islice

def N() -> Iterator[int]:
    i = 0 
    while True:
        yield i
        i += 1

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

# 1
def xor_seq() -> Iterator[int]:
    for a, b in cartesian(N(), N()):
        yield a ^ b

S = xor_seq()
for i in range(50):
    print(f"{i}: {next(S)}")

# 2
print(f"5151: {next(islice(xor_seq(), 5151))}")

# 3
def xor_seq_at(n: int) -> int:
    i = 0
    # calculate "coordinates"
    while n > i:
        n -= i
        if n > i:
            i += 1

    return (i - n) ^ n