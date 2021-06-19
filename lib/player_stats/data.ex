defmodule PlayerStats.Data do
  import Ecto.Query
  alias PlayerStats.{Repo, Schema}

  def get_player(
        %{first_name: first_name, last_name: last_name, team_name: team_name},
        %{id: season_id} = _season \\ current_season()
      ) do
    from(p in Schema.Player,
      join: ps in assoc(p, :player_seasons),
      on: ps.season_id == ^season_id,
      join: t in assoc(ps, :team),
      on: like(t.name, ^"%#{team_name}%"),
      where: p.first_name == ^first_name,
      where: p.last_name == ^last_name
    )
    |> Repo.one()
  end

  def player_disposals(%{id: player_id} = _player, %{id: season_id} = _season \\ current_season()) do
    from(gp in Schema.GamePlayer,
      join: g in assoc(gp, :game),
      join: ps in assoc(gp, :player_season),
      on: ps.season_id == ^season_id,
      where: gp.player_id == ^player_id,
      select: %{
        played_at: g.played_at,
        disposals: gp.disposals
      }
    )
    |> Repo.all()
  end

  defp current_season do
    Repo.get_by(Schema.Season, year: Date.utc_today().year())
  end
end
