defmodule PlayerStats.Repo.Migrations.AddFinalToGames do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add :final, :boolean, null: false, default: false
    end
  end
end
