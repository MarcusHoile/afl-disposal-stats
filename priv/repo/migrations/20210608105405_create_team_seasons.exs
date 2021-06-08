defmodule PlayerStats.Repo.Migrations.CreateTeamSeasons do
  use Ecto.Migration

  def change do
    create table(:team_seasons) do
      add :season_id, references(:seasons, on_delete: :delete_all), null: false
      add :team_id, references(:teams, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:team_seasons, [:season_id])
    create unique_index(:team_seasons, [:season_id, :team_id])
  end
end
