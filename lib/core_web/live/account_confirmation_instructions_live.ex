defmodule CoreWeb.AccountConfirmationInstructionsLive do
  use CoreWeb, :live_view

  alias Core.Users

  def render(assigns) do
    ~H"""
    <h1>Resend confirmation instructions</h1>

    <.simple_form :let={f} for={:account} id="resend_confirmation_form" phx-submit="send_instructions">
      <.input field={{f, :email_address}} type="email" label="Email" required />
      <:actions>
        <.button phx-disable-with="Sending..." type="submit" class="btn btn-primary">
          Resend confirmation instructions
        </.button>
      </:actions>
    </.simple_form>

    <p>
      <.link href={~p"/accounts/register"}>Register</.link>
      |
      <.link href={~p"/accounts/log_in"}>Log in</.link>
    </p>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event(
        "send_instructions",
        %{"account" => %{"email_address" => email_address}},
        socket
      ) do
    if account = Users.get_account_by_email_address(email_address) do
      Users.deliver_account_confirmation_instructions(
        account,
        &url(~p"/accounts/confirm/#{&1}")
      )
    end

    info =
      "If your email is in our system and it has not been confirmed yet, you will receive an email with instructions shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
