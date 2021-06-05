defmodule PlayerStatsWeb.PageController do
  use PlayerStatsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
