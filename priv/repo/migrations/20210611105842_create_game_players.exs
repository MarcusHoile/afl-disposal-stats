defmodule PlayerStats.Repo.Migrations.CreateGamePlayers do
  use Ecto.Migration

  def change do
    create table(:game_players) do
      add :kicks, :integer, default: 0, null: false
      add :handballs, :integer, default: 0, null: false
      add :disposals, :integer, default: 0, null: false
      add :goals, :integer, default: 0, null: false
      add :stats, :map
      add :game_id, references(:games, on_delete: :delete_all), null: false
      add :player_id, references(:players, on_delete: :delete_all), null: false
      add :player_season_id, references(:player_seasons, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:game_players, [:game_id, :player_id])
    create index(:game_players, [:player_season_id])
  end
end
