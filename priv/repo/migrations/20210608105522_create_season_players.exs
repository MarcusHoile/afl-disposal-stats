defmodule PlayerStats.Repo.Migrations.CreateSeasonPlayers do
  use Ecto.Migration

  def change do
    create table(:player_seasons) do
      add :guernsey_number, :integer, null: false
      add :team_season_id, references(:team_seasons, on_delete: :delete_all), null: false
      add :team_id, references(:teams, on_delete: :delete_all), null: false
      add :player_id, references(:players, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:player_seasons, [:team_season_id])
    create index(:player_seasons, [:team_id])
    create unique_index(:player_seasons, [:player_id, :team_id])
  end
end
