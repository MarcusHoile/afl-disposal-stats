defmodule PlayerStats.Factory do
  alias PlayerStats.Schema
  use ExMachina.Ecto, repo: PlayerStats.Repo

  # Factories

  def game_factory do
    %Schema.Game{
      external_id: sequence("external_id"),
      played_at: ~U[2000-01-01T00:00:00Z],
      round: sequence(:round, & &1),
      season: build(:season)
    }
  end

  def game_player_factory do
    %Schema.GamePlayer{
      player: build(:player),
      player_season: build(:player_season),
      game: build(:game)
    }
  end

  def page_factory do
    %Schema.Page{scraped: false, url: "http://example.com/path/to/page"}
  end

  def player_factory do
    %Schema.Player{first_name: sequence("Liam"), last_name: sequence("Ryan")}
  end

  def player_season_factory do
    %Schema.PlayerSeason{
      guernsey_number: "3",
      player: build(:player),
      team_season: build(:team_season)
    }
  end

  @afl_team_names [
    "Adelaide Crows",
    "Brisbane Lions",
    "Carlton Blues",
    "Collingwood Magpies",
    "Essendon Bombers",
    "Fremantle Dockers",
    "Geelong Cats",
    "Gold Coast Suns",
    "Greater Western Sydney Giants",
    "Hawthorn Hawks",
    "Melbourne Demons",
    "North Melbourne Kangaroos",
    "Port Adelaide Power",
    "Richmond Tigers",
    "St Kilda Saints",
    "Sydney Swans",
    "West Coast Eagles",
    "Western Bulldogs"
  ]
  def team_factory do
    %Schema.Team{name: sequence(:name, @afl_team_names)}
  end

  def season_factory do
    %Schema.Season{year: 2021}
  end

  def team_season_factory do
    %Schema.TeamSeason{
      team: build(:team),
      season: build(:season)
    }
  end

  def with_game_player(player_season, opts \\ []) do
    team = player_season.team_season.team
    season = player_season.team_season.season
    game = Keyword.get(opts, :game, build(:game, teams: [team], season: season))

    attrs =
      Keyword.merge(opts, game: game, player_season: player_season, player: player_season.player)

    insert(:game_player, attrs)
    player_season
  end
end
