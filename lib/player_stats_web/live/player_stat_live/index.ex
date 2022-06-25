defmodule PlayerStatsWeb.PlayerStatLive.Index do
  @moduledoc false
  use PlayerStatsWeb, :live_view

  @impl true
  def mount(params, _session, socket) do
    params = Map.merge(default_params(), params)

    socket =
      socket
      |> assign(:stats, list_stats(params))
      |> assign(:current_filters, current_filters(params))

    {:ok, socket}
  end

  # @impl true
  # def handle_params(params, _url, socket) do
  #   {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  # end

  defp list_stats(params) do
    filter = build_filter(params)
    games = team_games(filter)

    filter
    |> PlayerStats.list_players()
    |> Enum.map(&build_player_stat_row(&1, games, filter))
  end

  defp team_games(%{team_ids: team_ids} = filter) do
    games = PlayerStats.team_games(filter)

    team_ids
    |> Enum.reduce(%{}, fn team_id, acc ->
      games =
        Enum.filter(games, fn %{teams: teams} ->
          Enum.any?(teams, &(&1.id == team_id))
        end)

      Map.put(acc, team_id, games)
    end)
  end

  defp build_player_stat_row(
         %{
           game_players: game_players,
           player: %{first_name: first_name, id: player_id, last_name: last_name},
           team_season: %{team: %{id: team_id, name: team_name}}
         },
         team_games,
         filter
       ) do
    games = Map.get(team_games, team_id)
    disposals = Enum.map(game_players, & &1.disposals)

    %{
      first_name: first_name,
      last_name: last_name,
      player_id: player_id,
      team_name: team_name,
      form: player_form(games, game_players, filter),
      avg_disposals: avg_disposals(disposals, game_players),
      max_disposals: Enum.max(disposals),
      min_disposals: Enum.min(disposals)
    }
  end

  defp avg_disposals(disposals, game_players) do
    Enum.sum(disposals) / Enum.count(game_players)
  end

  defp player_form(games, game_players, %{min_disposals: min_disposals}) do
    Enum.map(games, fn %{id: game_id} ->
      game_players
      |> Enum.find(&(&1.game_id == game_id))
      |> case do
        nil ->
          %{played: false}

        %{disposals: disposals} ->
          %{
            played: true,
            min_disposals_difference: disposals - min_disposals
          }
      end
    end)
  end

  defp build_filter(params) do
    PlayerStats.Filter.build!(params)
  end

  defp current_filters(params) do
    params
    |> build_filter()
    |> Map.from_struct()
    |> Enum.reject(fn
      {_k, []} -> true
      {_k, nil} -> true
      {_k, _v} -> false
    end)
    |> Enum.into(%{})
  end

  def filter_value(value) when is_list(value) do
    Enum.join(value, ",")
  end

  def filter_value(value), do: value

  defp default_params do
    %{
      "current_year" => default_year(),
      "min_disposals" => "15",
      "max_avg_disposals" => "30"
    }
  end

  defp default_year do
    Application.get_env(:player_stats, :current_year, Date.utc_today().year())
  end

  defp game_form(%{min_disposals_difference: min_disposals_difference} = assigns) when min_disposals_difference > 0 do
    ~H"""
    <p class="bg-green-400 px-2">+<%= @min_disposals_difference %></p>
    """
  end

  defp game_form(%{min_disposals_difference: min_disposals_difference} = assigns) when min_disposals_difference < 0 do
    ~H"""
    <p class="bg-red-400 px-2">-<%= abs(@min_disposals_difference) %></p>
    """
  end

  defp game_form(%{min_disposals_difference: 0} = assigns) do
    ~H"""
    <p class="bg-gray-400 px-2">0</p>
    """
  end

  defp game_form(assigns) do
    ~H"""
    <p class="px-2">-</p>
    """
  end
end
