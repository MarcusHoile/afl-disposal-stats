defmodule PlayerStats.Crawler.UrlFilter do
  @moduledoc """
  Policy for which urls to scrape
  """
  import Ecto.Query, only: [from: 2]

  @behaviour Crawler.Fetcher.UrlFilter.Spec

  # @allowed_domain "mylocalopen.com"
  @allowed_domain "afltables.com"
  # @allowed_paths ~r/leagues|organisations/
  # @allowed_paths ~r/afl\/stats\/games\/2021\/031420210318|afl\/seas\/2021/
  @allowed_paths ~r/afl\/stats\/games\/20|afl\/seas\/20/
  def filter(url, _opts) do
    with true <- allowed_domain?(url),
         true <- allowed_path?(url),
         false <- visited?(url) do
      {:ok, true}
    else
      _ ->
        {:ok, false}
    end
  end

  defp allowed_domain?(url) do
    url
    |> URI.parse()
    |> case do
      %URI{host: @allowed_domain} ->
        true

      _ ->
        false
    end
  end

  defp allowed_path?(url) do
    url
    |> URI.parse()
    |> case do
      %{path: nil} ->
        false

      %{path: path} ->
        String.match?(path, @allowed_paths)
    end
  end

  defp visited?(url) do
    from(p in PlayerStats.Schema.Page, where: p.url == ^url, where: p.scraped)
    |> PlayerStats.Repo.exists?()
  end
end
