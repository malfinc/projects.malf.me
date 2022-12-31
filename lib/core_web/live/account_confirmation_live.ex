defmodule CoreWeb.AccountConfirmationLive do
  use CoreWeb, :live_view

  alias Core.Users

  def render(%{live_action: :edit} = assigns) do
    ~H"""
    <h1>Confirm Account</h1>

    <.simple_form :let={f} for={:account} id="confirmation_form" phx-submit="confirm_account">
      <.input field={{f, :token}} type="hidden" value={@token} />
      <:actions>
        <.button phx-disable-with="Confirming..." type="submit" class="btn btn-primary">Confirm my account</.button>
      </:actions>
    </.simple_form>

    <p>
      <.link href={~p"/accounts/register"}>Register</.link>
      |
      <.link href={~p"/accounts/log_in"}>Log in</.link>
    </p>
    """
  end

  def mount(params, _session, socket) do
    {:ok, assign(socket, token: params["token"]), temporary_assigns: [token: nil]}
  end

  # Do not log in the account after confirmation to avoid a
  # leaked token giving the account access to the account.
  def handle_event("confirm_account", %{"account" => %{"token" => token}}, socket) do
    case Users.confirm_account(token) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Account confirmed successfully.")
         |> redirect(to: ~p"/")}

      :error ->
        # If there is a current account and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the account themselves, so we redirect without
        # a warning message.
        case socket.assigns do
          %{current_account: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            {:noreply, redirect(socket, to: ~p"/")}

          %{} ->
            {:noreply,
             socket
             |> put_flash(:error, "Account confirmation link is invalid or it has expired.")
             |> redirect(to: ~p"/")}
        end
    end
  end
end