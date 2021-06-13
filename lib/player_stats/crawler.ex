defmodule PlayerStats.Crawler do
  def crawl(url \\ "https://afltables.com/afl/seas/2021.html", _opts \\ []) do
    Crawler.crawl(url,
      interval: 1_000,
      url_filter: PlayerStats.Crawler.UrlFilter,
      scraper: PlayerStats.Crawler.Scraper,
      save_to: "/Users/marcus/Documents/player-stats",
      workers: 1
    )
  end
end
