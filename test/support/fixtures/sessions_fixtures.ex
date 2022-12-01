defmodule Core.SessionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Core.Sessions` context.
  """

  def set_current_world_in_session(%{conn: conn, world: world}) do
    %{conn: conn |> Plug.Conn.put_session("world_id", world.id)}
  end

  @doc """
  Setup helper that registers and logs in accounts.

      setup :register_and_log_in_account

  It stores an updated connection and a registered account in the
  test context.
  """
  def register_and_log_in_account(%{conn: conn} = context) do
    account = Core.UsersFixtures.account_fixture()

    context
    |> Core.UsersFixtures.with_global_organization()
    |> Core.UsersFixtures.with_default_permission()
    |> Map.put(:conn, log_in_account(conn, account))
    |> Map.put(:account, account)
  end

  def make_account_an_administrator(%{account: account} = context) do
    context
    |> Core.UsersFixtures.with_administrator_permission()
    |> tap(fn _ ->
      {:ok, _} = Core.Users.join_organization_by_slug(account, "global", "administrator")
    end)
  end

  @doc """
  Logs the given `account` into the `conn`.

  It returns an updated `conn`.
  """
  def log_in_account(conn, account) do
    token = Core.Users.generate_account_session_token(account)

    conn
    |> Plug.Conn.put_session(:account_token, token)
  end
end
