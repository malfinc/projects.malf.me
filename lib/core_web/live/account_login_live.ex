defmodule CoreWeb.AccountLoginLive do
  use CoreWeb, :live_view

  def render(assigns) do
    ~H"""
    <h1>Sign in</h1>
    <.link href={~p"/auth/twitch"}>Sign in with Twitch</.link>
    """
  end

  def mount(_params, _session, socket) do
    email_address = live_flash(socket.assigns.flash, :email_address)
    {:ok, assign(socket, email_address: email_address), temporary_assigns: [email_address: nil]}
  end
end
