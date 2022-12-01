defmodule CoreWeb.AdminPageLive do
  @moduledoc false
  use CoreWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> (&{:ok, &1}).()
  end

  @impl true
  def render(assigns) do
    ~H"""
    Admin
    """
  end
end
