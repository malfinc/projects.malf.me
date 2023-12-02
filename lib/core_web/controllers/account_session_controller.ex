defmodule CoreWeb.AccountSessionController do
  use CoreWeb, :controller
  plug Ueberauth

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> CoreWeb.AccountAuthenticationHelpers.log_out_account()
  end

  def callback(%{assigns: %{ueberauth_failure: _}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: ~p"/")
  end

  def callback(%{assigns: %{ueberauth_auth: ueberauth_auth}} = conn, _params) do
    # This is an example of how you can pass the auth information to
    # a function that you implement that will register or login a user
    with {:ok, account} <- Core.Users.find_or_create_account_from_oauth(ueberauth_auth),
         {encoded_token, account_token} <-
           Core.Users.AccountToken.build_email_token(account, "confirm"),
         {:ok, _account_token} <- Core.Repo.insert(account_token),
         {:ok, _confirmation} <- Core.Users.confirm_account(encoded_token) do
      conn
      |> put_flash(:info, "Successfully authenticated.")
      |> CoreWeb.AccountAuthenticationHelpers.log_in_account(account, %{return_to: ~p"/lop"})
      |> configure_session(renew: true)
    else
      :error ->
        conn
        |> put_flash(:error, "Something went wrong")
        |> redirect(to: ~p"/")

      {:error, changeset} ->
        conn
        |> put_flash(:error, changeset)
        |> redirect(to: ~p"/")
    end
  end
end
