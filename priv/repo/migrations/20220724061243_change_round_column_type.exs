defmodule PlayerStats.Repo.Migrations.ChangeRoundColumnType do
  use Ecto.Migration

  def up do
    alter table(:games) do
      modify :round, :string, null: false
    end
  end

  def down do
    alter table(:games) do
      modify :round, :integer, null: false
    end
  end
end
