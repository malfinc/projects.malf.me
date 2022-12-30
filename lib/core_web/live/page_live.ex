defmodule CoreWeb.PageLive do
  @moduledoc false
  use CoreWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Loading...")
    |> (&{:ok, &1}).()
  end

  defp as(socket, :home, _params) do
    socket
    |> assign(:page_title, "Plotgenerator")
  end

  defp as(socket, :admin, _params) do
    socket
    |> assign(:page_title, "Admin")
  end

  defp as(socket, :faq, _params) do
    socket
    |> assign(:page_title, "Frequently Asked Questions")
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket
    |> as(socket.assigns.live_action, params)
    |> (&{:noreply, &1}).()
  end

  @impl true
  def render(%{live_action: :home} = assigns) do
    ~H"""

    """
  end

  @impl true
  def render(%{live_action: :admin} = assigns) do
    ~H"""
    The administrative dashboard.
    """
  end
end
