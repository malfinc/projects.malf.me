defmodule CoreWeb.AccountLoginLive do
  use CoreWeb, [:live_view, layout: :empty]

  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Sign In")
    |> (&{:ok, &1}).()
  end

  def render(assigns) do
    ~H"""
    <h1>Sign in</h1>
    <p>
      <.link href={~p"/auth/twitch"}>Authenticate via Twitch</.link>
    </p>
    """
  end
end
