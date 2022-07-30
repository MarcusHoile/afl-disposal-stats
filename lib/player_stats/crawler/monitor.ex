defmodule PlayerStats.Crawler.Monitor do
  @moduledoc """
  Kills the crawler once it has scraped all the data.
  """
  use GenServer
  import Ecto.Query

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl true
  def init(state) do
    if finished_scraping?(state) do
      stop_crawler(state)
      {:stop, :normal, state}
    else
      schedule_check()
      {:ok, state}
    end
  end

  @impl true
  def handle_info(:check_complete, state) do
    if finished_scraping?(state) do
      stop_crawler(state)
      {:stop, :normal, state}
    else
      schedule_check()
      {:noreply, state}
    end

    {:noreply, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  @interval_check 15 * 1000
  defp schedule_check do
    Process.send_after(self(), :check_complete, @interval_check)
  end

  defp stop_crawler(%{season: season} = state) do
    PlayerStats.add_round_to_finals_games(season)
    Crawler.stop(state)
  end

  defp finished_scraping?(%{round: round, season: season}) do
    from(g in PlayerStats.Schema.Game,
      join: s in assoc(g, :season),
      where: s.year == ^season,
      where: g.round == ^round,
      select: max(g.inserted_at)
    )
    |> PlayerStats.Repo.one()
    |> case do
      nil ->
        false

      inserted_at ->
        Timex.diff(Timex.now(), inserted_at) > @interval_check * 1_000
    end
  end
end
