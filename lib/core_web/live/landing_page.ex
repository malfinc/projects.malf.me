defmodule CoreWeb.Live.LandingPage do
  @moduledoc false
  use CoreWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> Utilities.Tuple.result(:ok)
  end

  @impl true
  def render(assigns) do
    ~H"""
    User
    """
  end
end
