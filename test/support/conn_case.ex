defmodule CoreWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use CoreWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  @__sid__ "x"

  use ExUnit.CaseTemplate

  using do
    quote do
      # The default endpoint for testing
      @endpoint CoreWeb.Endpoint

      use CoreWeb, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import CoreWeb.ConnCase
    end
  end

  setup tags do
    Core.DataCase.setup_sandbox(tags)

    {:ok, conn: build_conn(session: true, live: true)}
  end

  def build_conn(session: true, live: true) do
    Phoenix.ConnTest.build_conn()
    |> Phoenix.ConnTest.init_test_session(%{
      "__sid__" => @__sid__,
      "__opts__" => PhoenixLiveSession.init(pub_sub: Core.PubSub)
    })
    |> tap(&live_session_enabled/1)
  end

  defp live_session_enabled(conn) do
    PhoenixLiveSession.get(
      conn,
      @__sid__,
      PhoenixLiveSession.init(
        store: PhoenixLiveSession,
        pub_sub: Core.PubSub,
        signing_salt: "JKEx/AEF",
        key: "session"
      )
    )
  end

  @doc """
  Setup helper that registers and logs in accounts.

      setup :register_and_log_in_account

  It stores an updated connection and a registered account in the
  test context.
  """
  def register_and_log_in_account(%{conn: conn}) do
    account = Core.UsersFixtures.account_fixture()
    %{conn: log_in_account(conn, account), account: account}
  end

  @doc """
  Logs the given `account` into the `conn`.

  It returns an updated `conn`.
  """
  def log_in_account(conn, account) do
    token = Core.Users.generate_account_session_token(account)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:account_token, token)
  end
end
