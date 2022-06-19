defmodule PlayerStats.Schema.PlayerSeason do
  @moduledoc """
  Schema for a player season
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias PlayerStats.Schema

  schema "player_seasons" do
    field :guernsey_number, :integer

    belongs_to :player, Schema.Player
    belongs_to :team_season, Schema.TeamSeason

    has_many :game_players, Schema.GamePlayer

    timestamps()
  end

  @doc false
  def changeset(player_season, attrs) do
    player_season
    |> cast(attrs, [:guernsey_number])
    |> validate_required([:guernsey_number])
  end
end
