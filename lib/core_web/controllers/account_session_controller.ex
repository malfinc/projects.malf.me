defmodule CoreWeb.AccountSessionController do
  use CoreWeb, :controller

  def create(conn, %{"_action" => "registered"} = params) do
    create(conn, params, "Account created successfully!")
  end

  def create(conn, %{"_action" => "password_updated"} = params) do
    conn
    |> put_session(:account_return_to, ~p"/accounts/settings")
    |> create(params, "Password updated successfully!")
  end

  def create(conn, params) do
    create(conn, params, "Welcome back!")
  end

  defp create(conn, %{"account" => account_params}, info) do
    %{"email_address" => email_address, "password" => password} = account_params

    if account = Core.Users.get_account_by_email_address_and_password(email_address, password) do
      conn
      |> put_flash(:info, info)
      |> CoreWeb.AccountAuthenticationHelpers.log_in_account(account, account_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      conn
      |> put_flash(:error, "Invalid email or password")
      |> put_flash(:email_address, String.slice(email_address, 0, 160))
      |> redirect(to: ~p"/accounts/log_in")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> CoreWeb.AccountAuthenticationHelpers.log_out_account()
  end
end
