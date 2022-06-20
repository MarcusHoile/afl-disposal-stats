defmodule PlayerStats.Schema.Player do
  @moduledoc """
  Player schema
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias PlayerStats.Schema

  schema "players" do
    field :first_name, :string
    field :last_name, :string

    field :avg_disposals, :integer, virtual: true
    field :min_disposals, :integer, virtual: true
    field :max_disposals, :integer, virtual: true

    has_many :game_players, Schema.GamePlayer
    has_many :games, through: [:game_players, :game]
    has_many :player_seasons, Schema.PlayerSeason
    has_many :teams, through: [:player_seasons, :team]

    timestamps()
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:first_name, :last_name])
    |> validate_required([:first_name, :last_name])
  end
end
