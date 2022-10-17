defmodule CoreWeb.Live.<%= inspect schema.alias %>.IndexTest do
  use CoreWeb.LiveCase, async: true
  import Core.SessionsFixtures
  import <%= inspect context.module %>Fixtures
  import Core.UniversesFixtures

  setup :register_and_log_in_account
  setup :create_world
  setup :set_world_as_tenant
  setup :set_current_world_in_session
  setup :with_<%= schema.plural %>

  test "component renders", %{conn: conn, <%= schema.plural %>: <%= schema.plural %>} do
    {:ok, _view, html} =
      conn
      |> live("/worlds/<%= schema.plural %>")

    assert html =~ "<h2><%= schema.plural |> String.capitalize() %></h2>"
  end
end
