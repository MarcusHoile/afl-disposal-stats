defmodule PlayerStatsWeb.PlayerStatLive.Index do
  @moduledoc false
  use PlayerStatsWeb, :live_view

  alias PlayerStats.Repo

  @impl true
  def mount(params, _session, socket) do
    params = Map.merge(default_params(), params)

    socket =
      socket
      |> assign(:stats, list_stats(params))
      |> assign(:filter, filter(params))

    {:ok, socket}
  end

  # @impl true
  # def handle_params(params, _url, socket) do
  #   {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  # end

  defp list_stats(params) do
    params
    |> PlayerStats.Filter.build!()
    |> PlayerStats.list_game_players()
    |> Repo.preload([:player, :team])
    |> Enum.sort_by(&Decimal.round(&1.avg_disposals), &>=/2)
  end

  defp filter(params) do
    params
    |> PlayerStats.Filter.build!()
    |> Map.from_struct()
    |> Enum.reject(fn
      {_k, []} -> true
      {_k, nil} -> true
      {_k, _v} -> false
    end)
  end

  def filter_value(value) when is_list(value) do
    Enum.join(value, ",")
  end

  def filter_value(value), do: value

  defp default_params do
    %{
      "current_year" => default_year(),
      "min_disposals" => 15,
      "max_avg_disposals" => 30
    }
  end

  defp default_year do
    Application.get_env(:player_stats, :current_year, Date.utc_today().year())
  end
end
