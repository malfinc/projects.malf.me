defmodule CoreWeb.AccountLoginLive do
  use CoreWeb, :live_view

  def mount(_params, _session, socket) do
    email_address = live_flash(socket.assigns.flash, :email_address)

    socket
    |> assign(:page_title, "Sign In")
    |> assign(:form, to_form(%{"email_address" => email_address}, as: "account"))
    # |> (&{:ok, &1, temporary_assigns: [form: form], layout: {CoreWeb.Layouts, :empty}}).()
    |> (&{:ok, &1, layout: {CoreWeb.Layouts, :empty}}).()
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
