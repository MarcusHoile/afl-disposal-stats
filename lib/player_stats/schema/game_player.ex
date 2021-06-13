defmodule PlayerStats.Schema.GamePlayer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "game_players" do
    field :kicks, :integer, default: 0
    field :handballs, :integer, default: 0
    field :disposals, :integer, default: 0
    field :goals, :integer, default: 0
    field :stats, :map

    belongs_to :game, PlayerStats.Schema.Game
    belongs_to :player, PlayerStats.Schema.Player
    belongs_to :player_season, PlayerStats.Schema.PlayerSeason

    timestamps()
  end

  @doc false
  def changeset(game_player, attrs) do
    game_player
    |> cast(attrs, ~w(kicks handballs goals disposals)a)
    |> validate_required([])
  end
end
