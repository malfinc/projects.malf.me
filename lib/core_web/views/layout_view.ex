defmodule CoreWeb.LayoutView do
  use Phoenix.View,
    root: "lib/core_web/templates",
    namespace: CoreWeb
  use Phoenix.HTML
  use Phoenix.VerifiedRoutes,
    endpoint: CoreWeb.Endpoint,
    router: CoreWeb.Router,
    statics: CoreWeb.static_paths()

  # Import convenience functions from controllers
  import Phoenix.Controller,
    only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

  # Use all HTML functionality (forms, tags, etc)

  # Import LiveView and .heex helpers (live_render, live_patch, <.form>, etc)
  import Phoenix.LiveView
  import Phoenix.Component
  import Phoenix.LiveView.Helpers
  import CoreWeb.Live.LiveHelpers

  # Import basic rendering functionality (render, render_layout, etc)
  import Phoenix.View

  import CoreWeb.ErrorHelpers
  import CoreWeb.Gettext

  # Phoenix LiveDashboard is available only in development by default,
  # so we instruct Elixir to not warn if the dashboard route is missing.
  @compile {:no_warn_undefined, {Routes, :live_dashboard_path, 2}}
end
