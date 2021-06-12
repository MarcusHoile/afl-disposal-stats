defmodule PlayerStats.Factory do
  alias PlayerStats.{Repo, Schema}

  # Factories

  def build(:player) do
    %Schema.Player{first_name: "Liam", last_name: "Ryan"}
  end

  def build(:team) do
    %Schema.Team{name: "West Coast Eagles"}
  end

  # Convenience API

  def build(factory_name, attributes) do
    factory_name |> build() |> struct!(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end
end
