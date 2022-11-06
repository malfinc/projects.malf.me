defmodule CoreWeb.ErrorViewTest do
  use CoreWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.html" do
    assert is_map(render(CoreWeb.ErrorView, "404.html", []))
  end

  test "renders 500.html" do
    assert is_map(render(CoreWeb.ErrorView, "500.html", []))
  end
end
