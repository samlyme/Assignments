from collections import Counter, defaultdict, deque


V = ["P", "Q", "R", "S", "T"]
E = {("P", "Q"), ("Q", "R"), ("Q", "S"), ("R", "T")}

graph = {v : [] for v in V}
for e in E:
    a, b = e
    graph[a].append(b)
    graph[b].append(a)

degrees = Counter(len(edges) for edges in graph.values())

def bfs(start, end) -> list[str]:
    frontier = deque([start])
    prev = {start: None}
    while frontier:
        curr = frontier.popleft()
        if curr == end:
            break

        for n in graph[curr]:
            if n in prev:
                continue
            prev[n] = curr 
            frontier.append(n)

    if end not in prev: 
        return []

    out = [end]
    curr = prev[end]
    while curr:
        out.append(curr)
        curr = prev.get(curr)

    out.reverse
    return out
    
shortest_paths = []
for i in range(len(V)-1):
    for j in range(i+1, len(V)):
        shortest_paths.extend(bfs(V[i], V[j]))

centrality = Counter(shortest_paths)
print(centrality)
# Counter({'Q': 9, 'R': 7, 'P': 4, 'S': 4, 'T': 4})

distance = defaultdict(int)
for start in V:
    for end in V:
        if start == end:
            continue
        distance[start] += (len(bfs(start, end)) - 1)
print(distance)
print(sorted([(d, v) for v, d in distance.items()]))
# defaultdict(<class 'int'>, {'P': 8, 'Q': 5, 'R': 6, 'S': 8, 'T': 9})
# [(5, 'Q'), (6, 'R'), (8, 'P'), (8, 'S'), (9, 'T')]