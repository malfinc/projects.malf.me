defmodule CoreWeb.Live.<%= inspect schema.alias %>.ShowTest do
  use CoreWeb.LiveCase, async: true
  import Core.SessionsFixtures
  import <%= inspect context.module %>Fixtures
  import Core.UniversesFixtures

  setup :register_and_log_in_account
  setup :create_world
  setup :set_world_as_tenant
  setup :set_current_world_in_session
  setup :with_<%= schema.singular %>

  test "component renders", %{conn: conn, <%= schema.singular %>: <%= schema.singular %>} do
    {:ok, _view, html} =
      conn
      |> live("/worlds/<%= schema.plural %>/#{<%= schema.singular %>.id}")

    assert html =~ "<h2>#{<%= schema.singular %>.id}</h2>"
  end
end
