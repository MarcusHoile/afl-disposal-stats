defmodule PlayerStats.Schema.Game do
  use Ecto.Schema
  import Ecto.Changeset

  schema "games" do
    field :external_id, :string
    field :round, :integer
    belongs_to :season, PlayerStats.Schema.Season

    has_many :game_players, PlayerStats.Schema.GamePlayer
    many_to_many(:teams, PlayerStats.Schema.Team, join_through: "game_teams")

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:external_id, :round])
    |> validate_required([:external_id, :round])
  end
end