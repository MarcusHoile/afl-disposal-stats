defmodule PlayerStats.Crawler do
  @moduledoc """
  Web crawler
  """
  def crawl_season(round \\ 1, season \\ 2023, opts \\ default_options()) do
    url = "https://afltables.com/afl/seas/#{season}.html"
    opts = Keyword.merge(opts, season: season, round: round)
    {:ok, opts} = Crawler.crawl(url, opts)
    PlayerStats.Crawler.Monitor.start_link(opts)
  end

  def crawl_url(url, round \\ 1, season \\ 2023, opts \\ default_options()) do
    opts = Keyword.merge(opts, season: season, round: round)
    {:ok, opts} = Crawler.crawl(url, opts)
    PlayerStats.Crawler.Monitor.start_link(opts)
  end

  defp default_options, do: Application.get_env(:player_stats, __MODULE__)
end
