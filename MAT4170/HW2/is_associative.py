from typing import Literal

table = {
    "e": {"e": "e", "a": "a", "b": "b", "c": "c", "d": "d"},
    "a": {"e": "a", "a": "e", "b": "c", "c": "d", "d": "b"},
    "b": {"e": "b", "a": "d", "b": "e", "c": "a", "d": "c"},
    "c": {"e": "c", "a": "b", "b": "d", "c": "e", "d": "a"},
    "d": {"e": "d", "a": "c", "b": "a", "c": "b", "d": "e"}
}

vals = ["e", "a", "b", "c", "d"]
n = len(vals)

def check():
    for i in range(n):
        for j in range(n):
            for k in range(n):
                # left
                a, b, c = vals[i], vals[j], vals[k]
                # a * (b * c)
                left = table[a][table[b][c]]
                # (a * b) * c
                right = table[table[a][b]][c]

                if left != right:
                    print("Not associative!", (a, b, c), left, right)
                    return

check()