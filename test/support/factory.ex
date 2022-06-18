defmodule PlayerStats.Factory do
  alias PlayerStats.Schema
  use ExMachina.Ecto, repo: PlayerStats.Repo

  # Factories

  def page_factory do
    %Schema.Page{scraped: false, url: "http://example.com/path/to/page"}
  end

  def player_factory do
    %Schema.Player{first_name: "Liam", last_name: "Ryan"}
  end

  def team_factory do
    %Schema.Team{name: "West Coast Eagles"}
  end

  def season_factory do
    %Schema.Season{year: 2021}
  end

  def player_season_factory do
    %Schema.PlayerSeason{guernsey_number: "3", player: build(:player), season: build(:season)}
  end

  def team_season_factory do
    %Schema.TeamSeason{
      team: build(:team),
      season: build(:season)
    }
  end
end
