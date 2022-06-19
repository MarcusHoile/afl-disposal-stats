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
      join: gp in subquery(game_player_query(team_id, filter)),
      on: gp.player_id == p.id,
      distinct: p.id,
      preload: [game_players: ^game_player_preload_query(filter)]
    )
  end

  defp game_player_query(team_id, %{current_year: current_year, rounds: rounds}) do
    from(gp in Schema.GamePlayer,
      join: g in assoc(gp, :game),
      join: t in assoc(g, :teams),
      join: s in assoc(g, :season),
      limit: ^rounds,
      order_by: [desc: g.round],
      where: t.id == ^team_id,
      where: s.year == ^current_year
    )
  end

  defp game_player_preload_query(%{current_year: current_year, rounds: rounds}) do
    from(gp in Schema.GamePlayer,
      join: g in assoc(gp, :game),
      join: s in assoc(g, :season),
      limit: ^rounds,
      order_by: [desc: g.round],
      where: s.year == ^current_year
    )
  end
end
