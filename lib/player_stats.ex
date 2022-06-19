defmodule PlayerStats do
  @moduledoc false
  import Ecto.Query
  alias PlayerStats.{Repo, Schema}

  def list_players(%PlayerStats.Filter{team_ids: [t1, t2]} = filter) do
    t1
    |> team_list_players(filter)
    |> union_all(^team_list_players(t2, filter))
    |> Repo.all()
  end

  def list_players(%PlayerStats.Filter{team_ids: [team_id]} = filter) do
    team_id
    |> team_list_players(filter)
    |> Repo.all()
  end

  def list_game_players(_), do: []

  defp team_list_players(team_id, filter) do
    from(p in Schema.Player,
      join: gp in assoc(p, :game_players),
      where: gp.game_id in subquery(game_query(team_id, filter)),
      preload: [game_players: gp]
    )
  end

  defp game_query(team_id, %{current_year: current_year, rounds: rounds}) do
    from(g in Schema.Game,
      join: t in assoc(g, :teams),
      join: s in assoc(g, :season),
      where: t.id == ^team_id,
      group_by: [g.id, t.id],
      limit: ^rounds,
      order_by: [desc: g.round],
      select: g.id,
      where: s.year == ^current_year
    )
  end
end
