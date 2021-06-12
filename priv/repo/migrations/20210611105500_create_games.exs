defmodule PlayerStats.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :external_id, :string, null: false
      add :round, :integer, null: false
      add :season_id, references(:seasons, on_delete: :nothing)

      timestamps()
    end

    create index(:games, [:season_id])
  end
end
