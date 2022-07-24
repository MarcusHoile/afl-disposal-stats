defmodule PlayerStats.Crawler do
  @moduledoc """
  Web crawler
  """
  def crawl(url \\ "https://afltables.com/afl/seas/2022.html", opts \\ default_options()) do
    Crawler.crawl(url, opts)
  end

  defp default_options, do: Application.get_env(:player_stats, __MODULE__)
end
