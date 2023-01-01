defmodule CoreWeb.AdminPageLive do
  @moduledoc false
  use CoreWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Loading...")
    |> (&{:ok, &1}).()
  end

  defp as(socket, :dashboard, _params) do
    socket
    |> assign(:page_title, "Admin")
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket
    |> as(socket.assigns.live_action, params)
    |> (&{:noreply, &1}).()
  end

  @impl true
  def render(%{live_action: :dashboard} = assigns) do
    ~H"""
    The administrative dashboard.
    <p>
      <.link href={
        ~p"/auth/twitch?scope=user:read:email bits:read channel:read:redemptions channel:read:subscriptions"
      }>
        Reauthenticate via Twitch
      </.link>
    </p>
    """
  end
end
