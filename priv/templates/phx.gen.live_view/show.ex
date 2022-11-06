defmodule CoreWeb.Live.<%= inspect schema.alias %>.Show do
  @moduledoc false
  use CoreWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:page_title, "<%= schema.singular |> String.replace("_", " ") |> Utilities.titlecase() %>")}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    socket
    |> assign(:<%= schema.singular %>, <%= inspect context.module %>.get_<%= schema.singular %>!(id))
    |> Utilities.result(:noreply)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <h2><%= schema.singular |> String.replace("_", " ") |> Utilities.titlecase() %> <%%= @<%= schema.singular %>.id %></h2>
    """
  end
end
