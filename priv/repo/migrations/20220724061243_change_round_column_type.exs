defmodule PlayerStats.Repo.Migrations.ChangeRoundColumnType do
  use Ecto.Migration

  def change do
    alter table(:games) do
      modify :round, :string, null: false
    end
  end
end
