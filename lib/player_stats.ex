defmodule PlayerStats do
  @moduledoc false
  import Ecto.Query
  alias PlayerStats.{Repo, Schema}

  @final_rounds %{
    "Qualifying Final" => 1,
    "Elimination Final" => 1,
    "Semi Final" => 2,
    "Preliminary Final" => 3,
    "Grand Final" => 4
  }

  def previous_rounds(%{current_year: current_year}) do
    from(g in Schema.Game,
      join: t in assoc(g, :teams),
      join: s in assoc(g, :season),
      on: s.year == ^current_year,
      order_by: [desc: g.round],
      distinct: true,
      select: g.round
    )
    |> Repo.all()
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

  def add_round_to_finals_games(current_year) do
    current_year
    |> games_with_missing_round()
    |> Enum.each(fn game ->
      game
      |> Ecto.Changeset.change(round: get_final_round(current_year, game), final: true)
      |> Repo.update()
    end)
  end

  defp games_with_missing_round(current_year) do
    from(g in Schema.Game, join: s in assoc(g, :season), where: s.year == ^current_year, where: is_nil(g.round))
    |> Repo.all()
  end

  defp get_final_round(current_year, %{round_title: final_round_title}) do
    last_round =
      from(g in Schema.Game,
        join: s in assoc(g, :season),
        where: s.year == ^current_year,
        where: not is_nil(g.round),
        where: not g.final,
        select: max(g.round)
      )
      |> Repo.one()

    Map.get(@final_rounds, final_round_title, 0) + last_round
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
      preload: [game_players: {gp, :game}, player: p, team_season: :team]
    )
  end
end
