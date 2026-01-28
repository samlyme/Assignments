# ---------------------------------------------------------
# Shiny for Python "Hello World" Example
# ---------------------------------------------------------
# This short program creates a *reactive web app* using the
# Shiny for Python framework.
#
# It demonstrates the three essential parts of every Shiny app:
#   1. UI (what the user sees)
#   2. Server (what the app does)
#   3. App() (combines both into a running application)
#
# ---------------------------------------------------------

# Import the three main Shiny components you'll always need:
#   - App:   combines UI + server into a runnable app
#   - ui:    provides layout and input/output elements
#   - render: provides rendering decorators for reactive outputs
from shiny import App, ui, render


# ---------------------------------------------------------
# PART 1: Define the USER INTERFACE (UI)
# ---------------------------------------------------------
# The UI determines what appears on the page: headings,
# sliders, buttons, plots, text, etc.
#
# `ui.page_fluid()` is a layout helper that automatically
# adjusts to the browser width (a "fluid" responsive layout).
# Inside, we place other UI elements in the order they should appear.
app_ui = ui.page_fluid(
    # A simple level-2 heading (<h2>) at the top of the page.
    ui.h2("Hello Shiny!"),

    # An interactive slider input:
    #   - "n" is its *input ID* (how the server refers to it)
    #   - "Number" is the label shown next to the slider
    #   - 1 is the minimum value
    #   - 10 is the maximum value
    #   - 5 is the default starting position
    ui.input_slider("n", "Number", 1, 10, 5),

    # A *placeholder* for text output that the server will fill in.
    #   - "out" is its *output ID* (must match the server function name)
    ui.output_text("out")
)


# ---------------------------------------------------------
# PART 2: Define the SERVER LOGIC
# ---------------------------------------------------------
# The server function tells Shiny *how to react* when inputs change.
#
# Every Shiny server has the same signature:
#   def server(input, output, session):
#       ...
#
#   - input:   lets you read current values of UI inputs (e.g., input.n())
#   - output:  where you *declare* reactive outputs using decorators
#   - session: advanced object for managing the user's session
def server(input, output, session):

    # -----------------------------------------------------
    # Define a *reactive output* named "out".
    # -----------------------------------------------------
    # The decorators `@output` and `@render.text` work together:
    #   - `@output` registers this function as producing an output value
    #   - `@render.text` means it should return plain text for display
    #
    # The function name "out" **must match** the ID in ui.output_text("out")
    @output
    @render.text
    def out():
        # Inside this function, we can access current UI inputs.
        # `input.n()` calls the *reactive getter* for the slider named "n".
        #
        # Whenever the user moves the slider, Shiny automatically re-runs
        # this function and updates the displayed text on the page.
        return f"You picked {input.n()}"


# ---------------------------------------------------------
# PART 3: Combine UI and SERVER into an APP
# ---------------------------------------------------------
# The App() constructor creates a Shiny application object.
# It takes two arguments:
#   - app_ui: the user interface definition
#   - server: the reactive logic function
#
# When you run this file with:
#     python -m shiny run app.py
# Shiny launches a local web server and hosts this app.
app = App(app_ui, server)
