import networkx as nx

def main():
    G = nx.Graph()
    
    G.add_edge("A", "B")

    nx.draw(G)
    


if __name__ == "__main__":
    main()
