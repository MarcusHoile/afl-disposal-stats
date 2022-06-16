defmodule PlayerStats.Data do
  @moduledoc """
  Queries for player stat data
  """
  import Ecto.Query
  alias PlayerStats.{Repo, Schema}

  def game_players(filter) do
    current_year = Keyword.get(filter, :current_year, current_year())
    rounds = Keyword.get(filter, :rounds, default_rounds())

    from(gp in Schema.GamePlayer,
      as: :game_player,
      join: g in assoc(gp, :game),
      join: ps in assoc(gp, :player_season),
      join: ts in assoc(ps, :team_season),
      as: :team_season,
      join: s in assoc(ts, :season),
      on: s.year == ^current_year,
      where: g.round in ^rounds,
      distinct: gp.player_id
    )
    |> game_player_filter(filter)
    |> team_filter(filter)
    |> select([gp: gp, game_player: game_player], %{
      game_player
      | avg_disposals: gp.avg_disposals,
        min_disposals: gp.min_disposals
    })
  end

  defp game_player_filter(query, filter) do
    rounds = Keyword.get(filter, :rounds, default_rounds())
    disposal_count = Keyword.get(filter, :disposal_count, 0)

    subquery =
      from(gp in Schema.GamePlayer,
        join: g in assoc(gp, :game),
        join: ps in assoc(gp, :player_season),
        join: ts in assoc(ps, :team_season),
        as: :team_season,
        where: g.round in ^rounds,
        select: %{
          player_id: gp.player_id,
          game_count: count(gp.id),
          min_disposals: min(gp.disposals),
          avg_disposals: avg(gp.disposals)
        },
        group_by: gp.player_id
      )

    query
    |> join(:inner, [game_player: gp], gp2 in subquery(subquery),
      as: :gp,
      on:
        gp2.player_id == gp.player_id and
          gp2.game_count == ^length(rounds) and
          gp2.min_disposals >= ^disposal_count
    )
  end

  defp team_filter(query, filter) do
    filter
    |> Keyword.get(:team_ids)
    |> case do
      [] ->
        query

      team_ids ->
        where(query, [team_season: ts], ts.team_id in ^team_ids)
    end
  end

  defp current_year do
    Application.get_env(:player_stats, :current_year, Date.utc_today().year())
  end

  defp default_rounds, do: [1, 2]
end
