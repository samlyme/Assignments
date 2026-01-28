# demo1_graph.py
# -----------------------------
# What this demo shows:
# - A small random network (using NetworkX)
# - An interactive Plotly visualization you can zoom and pan
# - Sidebar controls to:
#     * filter nodes by minimum degree
#     * recolor nodes by a metric (degree, eigenvector centrality, or community)
#     * show/hide labels
#     * toggle fixed aspect ratio
#
# How to run (from an activated .venv):
#   python -m shiny run --reload demo1_graph.py --port 8000
#
# Open the URL printed in the terminal (usually http://127.0.0.1:8000)

from shiny import App, ui, render, reactive
import pandas as pd
import numpy as np
import networkx as nx
import plotly.graph_objects as go

# -----------------------------
# 1) Build a small example network + compute metrics
# -----------------------------

# Create a random graph with 60 nodes and 140 edges (seeded for reproducibility).
G = nx.gnm_random_graph(60, 140, seed=42)

# Compute a 2D layout for plotting (spring layout positions nodes based on forces).
pos = nx.spring_layout(G, seed=42)

# Basic centrality metrics:
deg = dict(G.degree())  # degree centrality (simple count of incident edges)
eig = nx.eigenvector_centrality(G, max_iter=1000)  # eigenvector centrality

# Detect communities using a greedy modularity approach.
# This returns sets of nodes; we map each node -> its community id (0,1,2,…).
communities = list(nx.algorithms.community.greedy_modularity_communities(G))
community_of = {n: cid for cid, C in enumerate(communities) for n in C}

# Convert node-level information into a DataFrame for easy filtering and plotting.
df_nodes = pd.DataFrame(
    {
        "node": list(G.nodes()),
        "x": [pos[n][0] for n in G.nodes()],
        "y": [pos[n][1] for n in G.nodes()],
        "degree": [deg[n] for n in G.nodes()],
        "eigenvector": [eig[n] for n in G.nodes()],
        "community": [community_of[n] for n in G.nodes()],
    }
)

# Build line segments for edges (Plotly draws lines by connecting x,y pairs; None breaks segments).
edges_x, edges_y = [], []
for u, v in G.edges():
    edges_x += [pos[u][0], pos[v][0], None]
    edges_y += [pos[u][1], pos[v][1], None]

# -----------------------------
# 2) Define the Shiny UI
# -----------------------------
# page_sidebar(): left sidebar for inputs, main area for outputs.
app_ui = ui.page_sidebar(
    # Sidebar with interactive controls
    ui.sidebar(
        ui.input_slider(
            "min_deg",
            "Min degree filter",
            min=0,
            max=int(df_nodes["degree"].max()),
            value=0,
            step=1,
        ),
        ui.input_select(
            "color_by",
            "Color nodes by",
            choices={
                "degree": "Degree",
                "eigenvector": "Eigenvector Centrality",
                "community": "Community",
            },
            selected="community",
        ),
        ui.input_checkbox("show_labels", "Show node labels", False),
        ui.input_checkbox("fix_aspect", "Fix aspect ratio (1:1)", True),
    ),

    # Main content
    ui.h3("Interactive Network"),
    ui.output_ui("graph_ui"),
    ui.p("Use your mouse to zoom and pan. Adjust filters and color options in the sidebar."),

    title="Demo 1 — Interactive Graph",
)

# -----------------------------
# 3) Server logic (reactivity + rendering)
# -----------------------------
def server(input, output, session):
    # Reactive calculation that filters node DataFrame by the min degree slider.
    @reactive.calc
    def filtered_nodes():
        return df_nodes[df_nodes["degree"] >= input.min_deg()]

    # Render the interactive Plotly graph into the Shiny UI.
    @output
    @render.ui
    def graph_ui():
        dfn = filtered_nodes()

        # The currently chosen color metric (column name in dfn).
        color_metric = input.color_by()

        # We'll stuff some extra values into "customdata" so hover tooltips can show them.
        custom = np.c_[
            dfn["node"],
            dfn["degree"],
            dfn["eigenvector"],
            dfn["community"],
        ]

        # Node scatter layer: colored by the chosen metric; optional labels above points.
        node_trace = go.Scatter(
            x=dfn["x"],
            y=dfn["y"],
            mode="markers+text" if input.show_labels() else "markers",
            text=[str(n) for n in dfn["node"]] if input.show_labels() else None,
            textposition="top center",
            marker=dict(
                size=12,
                color=dfn[color_metric],   # the actual color values
                showscale=True,            # show colorbar legend
                colorbar=dict(title=color_metric),
            ),
            hovertemplate=(
                "node = %{customdata[0]}<br>"
                "degree = %{customdata[1]}<br>"
                "eigenvector = %{customdata[2]:.3f}<br>"
                "community = %{customdata[3]}<extra></extra>"
            ),
            customdata=custom,
        )

        # Edge layer: thin gray lines behind the nodes.
        edge_trace = go.Scatter(
            x=edges_x,
            y=edges_y,
            mode="lines",
            line=dict(width=1, color="lightgray"),
            hoverinfo="skip",
        )

        # Build the figure with edges underneath nodes.
        fig = go.Figure(data=[edge_trace, node_trace])

        # Remove axis ticks/labels (network plots look cleaner without them).
        fig.update_layout(
            margin=dict(l=10, r=10, t=10, b=10),
            xaxis=dict(visible=False),
            yaxis=dict(visible=False),
        )

        # Keep aspect ratio equal if selected, so distances look proportional in x and y.
        if input.fix_aspect():
            fig.update_yaxes(scaleanchor="x", scaleratio=1)

        # Return the figure as embeddable HTML for Shiny to display.
        return ui.HTML(fig.to_html(include_plotlyjs="cdn", full_html=False))


# Create the Shiny app object (UI + server).
app = App(app_ui, server)
