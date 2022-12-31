defmodule CoreWeb.AccountRegistrationLive do
  use CoreWeb, :live_view

  alias Core.Users
  alias Core.Users.Account

  def render(assigns) do
    ~H"""
    <h1>Register</h1>

    <.link href={~p"/auth/twitch"}>Sign in with Twitch</.link>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Users.change_account_registration(%Account{})
    socket = assign(socket, changeset: changeset, trigger_submit: false)
    {:ok, socket, temporary_assigns: [changeset: nil]}
  end

  def handle_event("save", %{"account" => account_params}, socket) do
    case Users.register_account(account_params) do
      {:ok, account} ->
        {:ok, _} =
          Users.deliver_account_confirmation_instructions(
            account,
            &url(~p"/accounts/confirm/#{&1}")
          )

        changeset = Users.change_account_registration(account)
        {:noreply, assign(socket, trigger_submit: true, changeset: changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("validate", %{"account" => account_params}, socket) do
    changeset = Users.change_account_registration(%Account{}, account_params)
    {:noreply, assign(socket, changeset: Map.put(changeset, :action, :validate))}
  end
end
