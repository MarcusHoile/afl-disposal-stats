defmodule PlayerStatsWeb.ErrorViewTest do
  use PlayerStatsWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  @tag :skip
  test "renders 404.html" do
    assert render_to_string(PlayerStatsWeb.ErrorView, "404.html", []) == "Not Found"
  end

  @tag :skip
  test "renders 500.html" do
    assert render_to_string(PlayerStatsWeb.ErrorView, "500.html", []) == "Internal Server Error"
  end
end
