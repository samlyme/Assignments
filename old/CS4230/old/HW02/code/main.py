import networkx as nx


edges = [(1, 2), (1, 3), (2, 3), (3, 4), (4, 5), (4, 6), (5, 6), (5, 7), (6, 7), (7, 8)]
nodes = list(range(1, 9))

graph = nx.Graph()
graph.add_nodes_from(nodes)
graph.add_edges_from(edges)

print("density", nx.density(graph))

print("clustering coef", nx.clustering(graph, 3))

print("avg. path length", nx.average_shortest_path_length(graph))

print("modularity", nx.algorithms.community.modularity(graph, [{1,2,3}, {4,5,6,7,8}]))