defmodule PlayerStats.Crawler.ScraperTest do
  use PlayerStats.DataCase

  alias Crawler.Store.Page
  alias PlayerStats.Crawler.Scraper

  describe "scrape/1" do
    setup do
      PlayerStats.Seeds.insert_teams!()
      body = File.read!("test/support/fixtures/match_stats.html.text")

      page = %Page{
        body: body,
        url: "https://afltables.com/afl/stats/games/2021/031420210318.html"
      }

      {:ok, page: page}
    end

    test "saves each player", %{page: page} do
      {:ok, %Page{}} = Scraper.scrape(page)

      assert Repo.aggregate(Schema.Team, :count, :id) == 18
      assert Repo.aggregate(Schema.Player, :count, :id) == 46
    end

    test "saves game", %{page: page} do
      {:ok, %Page{}} = Scraper.scrape(page)

      assert Repo.aggregate(Schema.Team, :count, :id) == 18

      assert %{
               external_id: "031420210318",
               played_at: ~U[2021-03-18 00:00:00Z],
               round: 1
             } = Repo.one(Schema.Game)
    end

    test "saves each team_season we have not seen before", %{page: page} do
      season = build(:season)
      team = Repo.get_by!(Schema.Team, name: "Richmond Tigers")
      insert(:team_season, season: season, team: team)

      {:ok, %Page{}} = Scraper.scrape(page)

      assert Repo.aggregate(Schema.Team, :count, :id) == 18
      assert Repo.aggregate(Schema.TeamSeason, :count, :id) == 2
    end

    test "saves each player_season we have not seen before", %{page: page} do
      player = insert(:player, first_name: "Jack", last_name: "Graham")
      season = build(:season)
      team = Repo.get_by!(Schema.Team, name: "Richmond Tigers")
      team_season = insert(:team_season, season: season, team: team)

      insert(:player_season,
        team_season: team_season,
        player: player,
        guernsey_number: 34
      )

      {:ok, %Page{}} = Scraper.scrape(page)

      assert Repo.aggregate(Schema.Team, :count, :id) == 18
      assert Repo.aggregate(Schema.Player, :count, :id) == 46
      assert Repo.aggregate(Schema.PlayerSeason, :count, :id) == 46
    end

    test "saves each game_player and their stats", %{page: page} do
      {:ok, %Page{}} = Scraper.scrape(page)

      assert Repo.aggregate(Schema.Team, :count, :id) == 18
      assert Repo.aggregate(Schema.Player, :count, :id) == 46
      assert Repo.aggregate(Schema.GamePlayer, :count, :id) == 46

      %{game_players: [game_player]} =
        Schema.Player
        |> Repo.get_by!(first_name: "Jack", last_name: "Riewoldt")
        |> Repo.preload(:game_players)

      assert %{kicks: 9, handballs: 1, disposals: 10, goals: 4, stats: stats} = game_player

      assert %{
               "behinds" => "2",
               "bounces" => "",
               "brownlow_votes" => "",
               "clangers" => "3",
               "clearances" => "",
               "contested_marks" => "1",
               "contested_possessions" => "6",
               "disposals" => "10",
               "free_kicks_against" => "1",
               "free_kicks_for" => "1",
               "goal_assists" => "",
               "goals" => "4",
               "guernsey_number" => "8",
               "handballs" => "1",
               "hitouts" => "",
               "inside_50s" => "3",
               "kicks" => "9",
               "marks" => "4",
               "marks_inside_50" => "3",
               "one_percenters" => "",
               "percentage_of_game_playes" => "90",
               "player_name" => "Riewoldt, Jack",
               "rebound_50s" => "",
               "tackles" => "5",
               "uncontested_possessions" => "4"
             } == stats
    end

    test "saves each team_season", %{page: page} do
      {:ok, %Page{}} = Scraper.scrape(page)

      assert Repo.aggregate(Schema.Team, :count, :id) == 18
      assert Repo.aggregate(Schema.TeamSeason, :count, :id) == 2
    end

    @tag skip: "unskip when find_or_create player works"
    test "re-uses existing player", %{page: _page} do
    end

    test "saves page", %{page: page} do
      {:ok, %Page{}} = Scraper.scrape(page)

      assert %{url: "https://afltables.com/afl/stats/games/2021/031420210318.html"} =
               Repo.one(Schema.Page)
    end

    test "does not create a new page if one already exists", %{page: %{url: url} = page} do
      insert(:page, url: url)
      {:ok, %Page{}} = Scraper.scrape(page)

      assert %{url: "https://afltables.com/afl/stats/games/2021/031420210318.html", scraped: true} =
               Repo.one(Schema.Page)
    end
  end
end
