defmodule CoreWeb.AccountLoginLive do
  use CoreWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <header class="text-center">
        Sign in to account
        Don't have an account?
        <.link navigate={~p"/accounts/register"}>
          Sign up
        </.link>
        for an account now.
      </header>

      <.simple_form
        :let={f}
        id="login_form"
        for={:account}
        action={~p"/accounts/log_in"}
        as={:account}
        phx-update="ignore"
      >
        <.input field={{f, :email_address}} type="email" label="Email" required />
        <.input field={{f, :password}} type="password" label="Password" required />

        <:actions :let={f}>
          <.input field={{f, :remember_me}} type="checkbox" label="Keep me logged in" />
          <.link href={~p"/accounts/reset_password"}>
            Forgot your password?
          </.link>
        </:actions>
        <:actions>
          <.button type="submit" phx-disable-with="Sigining in..." class="btn btn-primary">
            Sign in <span aria-hidden="true">→</span>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email_address = live_flash(socket.assigns.flash, :email_address)
    {:ok, assign(socket, email_address: email_address), temporary_assigns: [email_address: nil]}
  end
end
