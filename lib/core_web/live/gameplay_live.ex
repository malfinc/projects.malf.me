defmodule CoreWeb.GameplayLive do
  @moduledoc false
  use CoreWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Loading...")
    |> (&{:ok, &1}).()
  end

  defp as(socket, :lop, _params) do
    socket
    |> assign(:page_title, "AggroCulture")
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket
    |> as(socket.assigns.live_action, params)
    |> (&{:noreply, &1}).()
  end

  @impl true
  def render(%{live_action: :lop} = assigns) do
    ~H"""
    <h1>Welcome to the AggroCulture</h1>

    <p>
      Still in progress.
    </p>
    """
  end
end
