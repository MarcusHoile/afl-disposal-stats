defmodule PlayerStats do
  @moduledoc false
  import Ecto.Query
  alias PlayerStats.{Repo, Schema}

  def previous_rounds(%{current_year: current_year}) do
    from(g in Schema.Game,
      join: t in assoc(g, :teams),
      join: s in assoc(g, :season),
      on: s.year == ^current_year,
      distinct: true,
      select: g.round
    )
    |> Repo.all()
    |> Enum.sort_by(&String.to_integer/1, :desc)
  end

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

  def teams do
    Repo.all(Schema.Team)
  end

  def team_games(%PlayerStats.Filter{current_year: current_year, team_ids: team_ids}) do
    from(g in Schema.Game,
      join: t in assoc(g, :teams),
      where: t.id in ^team_ids,
      join: s in assoc(g, :season),
      where: s.year == ^current_year,
      preload: [teams: t],
      order_by: [desc: g.round]
    )
    |> Repo.all()
  end

  defp team_list_players(team_id, %{current_year: current_year}) do
    from(ps in Schema.PlayerSeason,
      join: p in assoc(ps, :player),
      join: ts in assoc(ps, :team_season),
      on: ts.team_id == ^team_id,
      join: s in assoc(ts, :season),
      on: s.year == ^current_year,
      join: t in assoc(ts, :team),
      left_join: gp in assoc(ps, :game_players),
      left_join: g in assoc(gp, :game),
      preload: [game_players: {gp, :game}, player: p, team_season: :team]
    )
  end
end
