defmodule PlayerStats.Factory do
  alias PlayerStats.{Repo, Schema}

  # Factories

  def build(:page) do
    %Schema.Page{url: "http://example.com/path/to/page"}
  end

  def build(:player) do
    %Schema.Player{first_name: "Liam", last_name: "Ryan"}
  end

  def build(:team) do
    %Schema.Team{name: "West Coast Eagles"}
  end

  def build(:season) do
    %Schema.Season{year: 2021}
  end

  def build(:player_season) do
    %Schema.PlayerSeason{guernsey_number: "3"}
  end

  def build(:team_season) do
    %Schema.TeamSeason{}
  end

  # Convenience API

  def build(factory_name, attributes) do
    factory_name |> build() |> struct!(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end
end
