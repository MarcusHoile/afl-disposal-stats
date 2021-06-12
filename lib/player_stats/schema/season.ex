defmodule PlayerStats.Schema.Season do
  use Ecto.Schema
  import Ecto.Changeset
  alias PlayerStats.Schema

  schema "seasons" do
    field :year, :integer

    has_many :team_seasons, Schema.TeamSeason
    has_many :teams, through: [:team_seasons, :team]

    timestamps()
  end

  @doc false
  def changeset(season, attrs) do
    season
    |> cast(attrs, [:year])
    |> validate_required([:year])
  end
end
