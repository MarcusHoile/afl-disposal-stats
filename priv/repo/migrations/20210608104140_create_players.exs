defmodule PlayerStats.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :first_name, :string, null: false
      add :last_name, :string, null: false

      timestamps()
    end

  end
end
