defmodule PlayerStats do
  @moduledoc false
  import Ecto.Query
  alias PlayerStats.{Repo, Schema}

  def list_players(%PlayerStats.Filter{team_ids: [t1, t2]} = filter) do
    t1
    |> team_list_players(filter)
    |> union(^team_list_players(t2, filter))
    |> Repo.all()
  end

  def list_players(%PlayerStats.Filter{team_ids: [team_id]} = filter) do
    team_id
    |> team_list_players(filter)
    |> Repo.all()
  end

  def list_players(%PlayerStats.Filter{team_ids: []}), do: []

  defp team_list_players(team_id, %{min_disposals: min_disposals} = filter) do
    from(gp in Schema.GamePlayer,
      join: t in assoc(gp, :team),
      join: g in subquery(game_query(filter)),
      on: g.id == gp.game_id,
      where: t.id == ^team_id,
      where: gp.disposals >= ^min_disposals,
      group_by: [gp.player_id, t.name],
      select: %{
        player_id: gp.player_id,
        avg_disposals: fragment("?::float", avg(gp.disposals)),
        games_played: count(gp.id),
        min_disposals: fragment("? as min_disposals", min(gp.disposals)),
        max_disposals: max(gp.disposals),
        team_name: t.name
      }
    )
  end

  defp game_query(%{current_year: current_year, rounds: rounds}) do
    from(g in Schema.Game,
      join: t in assoc(g, :teams),
      join: s in assoc(g, :season),
      on: s.year == ^current_year,
      limit: ^rounds,
      order_by: [desc: g.round]
    )
  end
end
