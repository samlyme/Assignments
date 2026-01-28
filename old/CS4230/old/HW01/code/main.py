from typing import Counter

V = {"A", "B", "C", "D", "E"}
E = {("A", "B"), ("A", "C"), ("B", "C"), ("B", "D"), ("D", "E")}

graph = {v : [] for v in V}
for e in E:
    a, b = e
    graph[a].append(b)
    graph[b].append(a)

degrees = Counter(len(edges) for edges in graph.values())

for degree, count in degrees.items():
    print(f"{count} nodes have degree {degree}")

# 3 nodes have degree 2
# 1 nodes have degree 3
# 1 nodes have degree 1

import matplotlib.pyplot as plt  # noqa: E402

fig, ax = plt.subplots()
degree = list(degrees.keys())
count = list(degrees.values())

print(degree)
print(count)

ax.bar(degree, count, align="edge")

ax.set_xticks(range(min(degree), max(degree) + 1))
ax.set_yticks(range(min(count), max(count) + 1))

ax.set_xlabel("Degree")
ax.set_ylabel('No. of Nodes')

ax.set_title('Degree distribution of nodes')

plt.savefig("../bar.png")