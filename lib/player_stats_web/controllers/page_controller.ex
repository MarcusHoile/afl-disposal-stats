defmodule PlayerStatsWeb.PageController do
  use PlayerStatsWeb, :controller

  def index(conn, _params) do
    data =
      %{first_name: "Jack", last_name: "Riewoldt", team_name: "Richmond"}
      |> PlayerStats.Data.get_player()
      |> PlayerStats.Data.player_disposals()

    render(conn, "index.html", data: data)
  end
end
