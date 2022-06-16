defmodule PlayerStats do
  @moduledoc false
  import Ecto.Query
  alias PlayerStats.{Repo, Schema}

  def list_game_players(%PlayerStats.Filter{current_year: current_year} = filter) do
    from(gp in Schema.GamePlayer,
      as: :game_player,
      join: g in assoc(gp, :game),
      as: :game,
      join: ps in assoc(gp, :player_season),
      join: ts in assoc(ps, :team_season),
      as: :team_season,
      join: s in assoc(ts, :season),
      on: s.year == ^current_year,
      distinct: gp.player_id
    )
    |> round_filter(filter)
    |> game_player_filter(filter)
    |> team_filter(filter)
    |> select([gp: gp, game_player: game_player], %{
      game_player
      | avg_disposals: gp.avg_disposals,
        min_disposals: gp.min_disposals,
        max_disposals: gp.max_disposals
    })
    |> Repo.all()
  end

  def list_game_players(_), do: []

  defp round_filter(query, %{rounds: []}), do: query

  defp round_filter(query, %{rounds: rounds}) do
    where(query, [game: g], g.round in ^rounds)
  end

  defp game_player_filter(query, %{min_disposals: min_disposals, rounds: []}) do
    query
    |> join(:inner, [game_player: gp], gp2 in subquery(game_player_subquery()),
      as: :gp,
      on: gp2.player_id == gp.player_id and gp2.min_disposals >= ^min_disposals
    )
  end

  defp game_player_filter(query, %{min_disposals: min_disposals, rounds: rounds} = filter) do
    subquery =
      game_player_subquery()
      |> round_filter(filter)

    query
    |> join(:inner, [game_player: gp], gp2 in subquery(subquery),
      as: :gp,
      on:
        gp2.player_id == gp.player_id and
          gp2.game_count == ^length(rounds) and
          gp2.min_disposals >= ^min_disposals
    )
  end

  defp game_player_subquery do
    from(gp in Schema.GamePlayer,
      join: g in assoc(gp, :game),
      as: :game,
      join: ps in assoc(gp, :player_season),
      join: ts in assoc(ps, :team_season),
      as: :team_season,
      select: %{
        player_id: gp.player_id,
        game_count: count(gp.id),
        min_disposals: min(gp.disposals),
        max_disposals: max(gp.disposals),
        avg_disposals: avg(gp.disposals)
      },
      group_by: gp.player_id
    )
  end

  defp team_filter(query, %{team_ids: []}), do: query

  defp team_filter(query, %{team_ids: team_ids}) do
    where(query, [team_season: ts], ts.team_id in ^team_ids)
  end
end
