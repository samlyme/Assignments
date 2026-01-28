import itertools

def all_digraphs(n: int):
    if n <= 0:
        return []

    # Edge positions to toggle (ordered pairs)
    positions = []
    for i in range(n):
        for j in range(n):
            positions.append((i, j))

    num_edges = len(positions)  # n*(n-1) if no self-loops; n*n if with self-loops

    graphs = []
    for bits in itertools.product([0, 1], repeat=num_edges):
        # start with all zeros
        adj = [[0]*n for _ in range(n)]
        for (k, (i, j)) in enumerate(positions):
            adj[i][j] = bits[k]
        # if self_loops is False, diagonal is already zero by construction
        graphs.append(adj)

    return graphs

def is_transitive(r: list[list[int]]) -> bool:
    for i in range(4):
        for j in range(4):
            for k in range(4):
                if r[i][j] and r[j][k]:
                    if not r[i][k]:
                        return False
    return True

n = 4
relations = all_digraphs(n)
print(relations[0])

num_transitive = sum(is_transitive(r) for r in relations)
print(num_transitive)