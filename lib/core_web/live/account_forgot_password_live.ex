defmodule CoreWeb.AccountForgotPasswordLive do
  use CoreWeb, :live_view

  alias Core.Users

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <p class="text-center">
        Forgot your password?
        We'll send a password reset link to your inbox
      </p>

      <.simple_form :let={f} id="reset_password_form" for={:account} phx-submit="send_email">
        <.input field={{f, :email_address}} type="email" placeholder="Email" required />
        <:actions>
          <.button phx-disable-with="Sending..." type="submit" class="btn btn-primary">
            Send password reset instructions
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event("send_email", %{"account" => %{"email_address" => email_address}}, socket) do
    if account = Users.get_account_by_email_address(email_address) do
      Users.deliver_account_reset_password_instructions(
        account,
        &url(~p"/accounts/reset_password/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions to reset your password shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
