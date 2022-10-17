defmodule CoreWeb.Live.<%= inspect schema.alias %>.Index do
  @moduledoc false
  use CoreWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:page_title, "<%= schema.plural |> String.replace("_", " ") |> Utilities.titlecase() %>")}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    socket
    |> assign(:<%= schema.plural %>, <%= inspect context.module %>.list_<%= schema.plural %>())
    |> Utilities.result(:noreply)
  end

  @impl true
  def handle_event("create", _, socket) do
    <%= inspect context.module %>.create_<%= schema.singular %>()
    |> case do
      {:ok, <%= schema.singular %>} ->
        socket |> push_redirect(to: Routes.live_path(socket, CoreWeb.Live.<%= inspect schema.alias %>.Show, <%= schema.singular %>))

      {:error, changeset} ->
        socket |> assign(:errors, changeset)
    end
    |> Utilities.result(:noreply)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <h2><%= schema.plural |> String.replace("_", " ") |> Utilities.titlecase() %></h2>
    <div class="card-grid">
      <div class="card card--ghost">
        <div class="card-body">
          <button class="btn btn-success" phx-click="create" phx-page-loading>Create <%= schema.singular |> String.replace("_", " ") |> Utilities.titlecase() %></button>
        </div>
      </div>
      <%%= for <%= schema.singular %> <- @<%= schema.plural %> do %>
        <div class="card">
          <div class="card-body">
            <h5 class="card-title"><%%= link to: Routes.live_path(@socket, CoreWeb.Live.<%= inspect schema.alias %>.Show, <%= schema.singular %>) do %><%%= <%= schema.singular %>.id %><%% end %></h5>
            <p class="card-text">Some quick example text to build on the card title and make up the bulk of the card's content.</p>
          </div>
          <div class="card-footer">
            <small class="text-muted">Last updated <%%= <%= schema.singular %>.updated_at %></small>
          </div>
        </div>
      <%% end %>
    </div>
    """
  end
end
