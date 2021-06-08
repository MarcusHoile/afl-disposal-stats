defmodule PlayerStats.Schema.Team do
  use Ecto.Schema
  import Ecto.Changeset
  alias PlayerStats.Schema

  schema "teams" do
    field :name, :string

    has_many :team_seasons, Schema.TeamSeason

    timestamps()
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
