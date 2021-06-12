defmodule PlayerStats.Crawler.ScraperTest do
  use PlayerStats.DataCase

  alias Crawler.Store.Page
  alias PlayerStats.Crawler.Scraper

  describe "scrape/1" do
    setup do
      body = File.read!("test/support/fixtures/match_stats.html.text")

      page = %Page{
        body: body,
        url: "https://afltables.com/afl/stats/games/2021/031420210318.html"
      }

      {:ok, page: page}
    end

    test "saves each player", %{page: page} do
      {:ok, %Page{}} = Scraper.scrape(page)

      assert PlayerStats.Repo.aggregate(Schema.Team, :count, :id) == 18
      assert PlayerStats.Repo.aggregate(Schema.Player, :count, :id) == 46
    end

    @tag :skip
    test "saves each team_season we have not seen before" do
    end

    @tag :skip
    test "saves each player_season we have not seen before" do
    end

    @tag :skip
    test "saves each game_player and their stats" do
    end

    @tag :skip
    test "saves each team_season" do
    end

    @tag :skip
    test "re-uses existing player" do
    end

    @tag :skip
    test "saves each player's stats" do
      body = File.read!("test/support/fixtures/match_stats.html.text")
      page = %Page{body: body}
      {:ok, %Page{}} = Scraper.scrape(page)
    end

    @tag :skip
    test "saves page" do
    end
  end
end
