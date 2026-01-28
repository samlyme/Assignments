# demo3_dynamic_results.py
# -----------------------------
# What this demo shows:
# - Dynamic "KPI cards" (count, mean, max) that update when you adjust filters
# - A bar chart of the top-K nodes by the selected metric
# - A data table that reflects the current filter
#
# How to run (from an activated .venv):
#   python -m shiny run --reload demo3_dynamic_results.py --port 8002

from shiny import App, ui, render, reactive
import pandas as pd
import numpy as np
import networkx as nx
import plotly.express as px

# -----------------------------
# 1) Build a small example dataset (graph -> metrics -> DataFrame)
# -----------------------------
G = nx.gnm_random_graph(80, 220, seed=21)

deg = dict(G.degree())
eig = nx.eigenvector_centrality(G, max_iter=1000)

# Each row is a node, with columns for two metrics we'll use.
df = pd.DataFrame(
    {
        "node": list(G.nodes()),
        "degree": [deg[n] for n in G.nodes()],
        "eigenvector": [eig[n] for n in G.nodes()],
    }
)

# -----------------------------
# 2) Define the Shiny UI
# -----------------------------
app_ui = ui.page_sidebar(
    ui.sidebar(
        # Choose the metric all displays should use.
        ui.input_select(
            "metric",
            "Metric",
            {"degree": "Degree", "eigenvector": "Eigenvector"},
            selected="degree",
        ),
        # Filter rows by a minimum threshold on the chosen metric.
        # For simplicity, we set slider bounds 0..10 (works fine for degree; eigenvector is in [0,1]).
        ui.input_slider("min_val", "Minimum value filter", min=0, max=10, value=0, step=1),
        # How many bars should appear in the chart.
        ui.input_numeric("top_k", "Top K (for chart)", value=10, min=3, max=30, step=1),
    ),

    ui.h3("Dynamic Results"),
    # KPI "cards" across the top (layout_columns lays them side-by-side)
    ui.layout_columns(
        ui.card(ui.card_header("Count"), ui.output_text("kpi_count")),
        ui.card(ui.card_header("Mean"), ui.output_text("kpi_mean")),
        ui.card(ui.card_header("Max"), ui.output_text("kpi_max")),
    ),
    # Chart and table in stacked cards
    ui.card(ui.card_header("Top Entities (Bar Chart)"), ui.output_ui("bar_chart")),
    ui.card(ui.card_header("Details (Table)"), ui.output_table("table")),

    title="Demo 3 — Dynamic KPIs, Chart, Table",
)

# -----------------------------
# 3) Server logic (reactive filter + KPI text + chart + table)
# -----------------------------
def server(input, output, session):
    # Central reactive filter: returns a filtered copy of the DataFrame
    # based on the selected metric and the minimum threshold.
    @reactive.calc
    def filtered_df():
        m = input.metric()       # "degree" or "eigenvector"
        thr = input.min_val()    # min threshold from slider
        return df[df[m] >= thr].copy()

    # KPI 1: Row count after filtering
    @output
    @render.text
    def kpi_count():
        return str(len(filtered_df()))

    # KPI 2: Mean of selected metric after filtering (or "—" if empty)
    @output
    @render.text
    def kpi_mean():
        m = input.metric()
        sub = filtered_df()
        return f"{sub[m].mean():.3f}" if len(sub) else "—"

    # KPI 3: Max of selected metric after filtering (or "—" if empty)
    @output
    @render.text
    def kpi_max():
        m = input.metric()
        sub = filtered_df()
        return f"{sub[m].max():.3f}" if len(sub) else "—"

    # Bar chart of the top-K nodes by the selected metric
    @output
    @render.ui
    def bar_chart():
        m = input.metric()
        k = int(input.top_k())

        sub = filtered_df()
        if len(sub) == 0:
            # If filtering removed everything, show a friendly message instead of a blank chart.
            return ui.HTML("<em>No rows after filtering. Try lowering the minimum value.</em>")

        # Take the top-K rows by metric (largest first).
        top = sub.nlargest(k, m)

        # Plotly makes it easy to build a labeled bar chart.
        fig = px.bar(top, x="node", y=m, title=f"Top {k} by {m}")
        fig.update_layout(
            margin=dict(l=10, r=10, t=40, b=10),
            xaxis_title="node",
            yaxis_title=m,
        )

        # Return as HTML so Shiny can embed it.
        return ui.HTML(fig.to_html(include_plotlyjs="cdn", full_html=False))

    # Data table reflecting the current filter (sorted by chosen metric descending)
    @output
    @render.table
    def table():
        m = input.metric()
        sub = filtered_df()
        return sub.sort_values(m, ascending=False)


app = App(app_ui, server)
