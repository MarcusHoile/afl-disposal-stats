defmodule PlayerStatsWeb.PageController do
  use PlayerStatsWeb, :controller
  alias PlayerStats.Repo

  def index(conn, params) do
    team_ids = Map.get(params, "team_ids", [])
    disposal_count = Map.get(params, "disposals", 0)

    data =
      [team_ids: team_ids, disposal_count: disposal_count]
      |> PlayerStats.Data.game_players()
      |> Repo.all()
      |> Repo.preload([:player, :team])
      |> Enum.map(fn %{
                       avg_disposals: avg_disposals,
                       min_disposals: min_disposals,
                       team: %{name: team_name},
                       player: %{first_name: first_name, last_name: last_name}
                     } ->
        %{
          first_name: first_name,
          last_name: last_name,
          avg_disposals: avg_disposals,
          min_disposals: min_disposals,
          team_name: team_name
        }
      end)
      |> Enum.sort_by(& &1.avg_disposals, &>=/2)

    render(conn, "index.html", data: data)
  end
end
