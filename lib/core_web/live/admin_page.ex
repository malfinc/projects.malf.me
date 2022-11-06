defmodule CoreWeb.Live.AdminPage do
  @moduledoc false
  use CoreWeb.Live, :view

  on_mount({CoreWeb.Live, :require_administrative_privilages})

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> Utilities.Tuple.result(:ok)
  end

  @impl true
  def render(assigns) do
    ~H"""
    Admin
    """
  end
end
