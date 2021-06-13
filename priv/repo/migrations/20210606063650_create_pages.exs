defmodule PlayerStats.Repo.Migrations.CreatePages do
  use Ecto.Migration

  def change do
    create table(:pages) do
      add :url, :string, null: false
      add :scraped, :boolean, null: false

      timestamps()
    end

  end
end
