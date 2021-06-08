defmodule PlayerStats.Schema.TeamSeason do
  use Ecto.Schema
  import Ecto.Changeset
  alias PlayerStats.Schema

  schema "team_seasons" do
    belongs_to :season, Schema.Season
    belongs_to :team, Schema.Team

    has_many :player_seasons, Schema.PlayerSeason
    has_many :players, through: [:player_seasons, :player]

    timestamps()
  end

  @doc false
  def changeset(team_season, attrs) do
    team_season
    |> cast(attrs, [])
    |> validate_required([])
  end
end
