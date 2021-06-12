defmodule PlayerStats.Repo.Migrations.AddGameTeams do
  use Ecto.Migration

  def change do
    create table(:game_teams, primary_key: false) do
      add(:game_id, references(:games, on_delete: :delete_all), null: false)
      add(:team_id, references(:teams, on_delete: :delete_all), null: false)
    end

    create(index(:game_teams, [:game_id, :team_id]))
  end
end
