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

  defp team_list_players(team_id, filter) do
    from(p in Schema.Player,
      join: gp in assoc(p, :game_players),
      join: t in assoc(gp, :team),
      join: g in subquery(game_query(filter)),
      group_by: [p.id, t.id],
      distinct: true,
      order_by: {:desc, fragment("avg_disposals")},
      where: t.id == ^team_id,
      select: %{
        first_name: p.first_name,
        last_name: p.last_name,
        avg_disposals: fragment("?::float as avg_disposals", avg(gp.disposals)),
        team_name: t.name,
        min_disposals: min(gp.disposals),
        max_disposals: max(gp.disposals)
      }
    )
    |> max_avg_disposals_filter(filter)
    |> min_disposals_filter(filter)
  end

  defp min_disposals_filter(query, %{min_disposals: min_disposals}) do
    subquery =
      from(gp in Schema.GamePlayer,
        group_by: gp.player_id,
        select: %{player_id: gp.player_id, disposals: min(gp.disposals)}
      )

    query
    |> join(:inner, [p], gp in subquery(subquery), on: gp.player_id == p.id and gp.disposals >= ^min_disposals)
  end

  defp max_avg_disposals_filter(query, %{max_avg_disposals: nil}), do: query

  defp max_avg_disposals_filter(query, %{max_avg_disposals: max_avg_disposals}) do
    subquery =
      from(gp in Schema.GamePlayer,
        group_by: gp.player_id,
        select: %{player_id: gp.player_id, disposals: avg(gp.disposals)}
      )

    query
    |> join(:inner, [p], gp in subquery(subquery), on: gp.player_id == p.id and gp.disposals <= ^max_avg_disposals)
  end

  defp game_query(%{current_year: current_year, rounds: rounds}) do
    from(g in Schema.Game,
      join: t in assoc(g, :teams),
      join: s in assoc(g, :season),
      limit: ^rounds,
      order_by: [desc: g.round],
      where: s.year == ^current_year
    )
  end
end
