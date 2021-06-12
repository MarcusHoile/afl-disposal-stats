defmodule PlayerStats.Schema.PlayerSeason do
  use Ecto.Schema
  import Ecto.Changeset
  alias PlayerStats.Schema

  schema "player_seasons" do
    field :guernsey_number, :integer

    belongs_to :player, Schema.Player
    belongs_to :season, Schema.Season
    belongs_to :team, Schema.Team
    belongs_to :team_season, Schema.TeamSeason

    timestamps()
  end

  @doc false
  def changeset(player_season, attrs) do
    player_season
    |> cast(attrs, [:guernsey_number])
    |> validate_required([:guernsey_number])
  end
end
