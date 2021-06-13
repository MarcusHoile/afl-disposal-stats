defmodule PlayerStats.Crawler.UrlFilter do
  import Ecto.Query, only: [from: 2]

  @behaviour Crawler.Fetcher.UrlFilter.Spec

  # @allowed_domain "mylocalopen.com"
  @allowed_domain "afltables.com"
  # @allowed_paths ~r/leagues|organisations/
  # @allowed_paths ~r/afl\/stats\/games\/2021\/031420210318|afl\/seas\/2021/
  @allowed_paths ~r/afl\/stats\/games\/2021|afl\/seas\/2021/
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
      %{authority: @allowed_domain} ->
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
    from(p in PlayerStats.Schema.Page, where: p.url == ^url)
    |> PlayerStats.Repo.exists?()
  end
end
