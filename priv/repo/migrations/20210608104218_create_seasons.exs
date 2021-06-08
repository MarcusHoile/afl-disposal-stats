defmodule PlayerStats.Repo.Migrations.CreateSeasons do
  use Ecto.Migration

  def change do
    create table(:seasons) do
      add :year, :integer, null: false

      timestamps()
    end

  end
end
