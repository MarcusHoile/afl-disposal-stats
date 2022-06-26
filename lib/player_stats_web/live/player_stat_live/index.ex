defmodule PlayerStatsWeb.PlayerStatLive.Index do
  @moduledoc false
  use PlayerStatsWeb, :live_view

  @impl true
  def mount(params, _session, socket) do
    params = Map.merge(default_params(), params)
    filter = build_filter(params)
    previous_rounds = PlayerStats.previous_rounds(filter)

    socket =
      socket
      |> assign(:stats, list_stats(filter, previous_rounds))
      |> assign(:current_filters, current_filters(filter))
      |> assign(:previous_rounds, previous_rounds)

    {:ok, socket}
  end

  # @impl true
  # def handle_params(params, _url, socket) do
  #   {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  # end

  defp list_stats(filter, previous_rounds) do
    data = %{games: team_games(filter), previous_rounds: previous_rounds}

    filter
    |> PlayerStats.list_players()
    |> Enum.map(&build_player_stat_row(&1, data, filter))
    |> Enum.sort_by(& &1.avg_disposals, :desc)
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
         game_data,
         filter
       ) do
    disposals = Enum.map(game_players, & &1.disposals)
    game_data = Map.merge(game_data, %{game_players: game_players, team_id: team_id})

    %{
      first_name: first_name,
      last_name: last_name,
      player_id: player_id,
      team_name: team_name,
      form: player_form(game_data, filter),
      avg_disposals: avg_disposals(disposals, game_players),
      max_disposals: Enum.max(disposals),
      min_disposals: Enum.min(disposals)
    }
  end

  defp avg_disposals(disposals, game_players) do
    Enum.sum(disposals) / Enum.count(game_players)
  end

  defp player_form(
         %{
           games: games,
           game_players: game_players,
           previous_rounds: previous_rounds,
           team_id: team_id
         },
         %{min_disposals: min_disposals}
       ) do
    team_games =
      games
      |> Map.get(team_id, [])
      |> Enum.group_by(& &1.round)

    previous_rounds
    |> Enum.map(fn round ->
      %{id: game_id} =
        team_games
        |> Map.get(round, [])
        |> List.first(%PlayerStats.Schema.Game{round: round})

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
      |> Map.put(:round, round)
      |> Map.put(:bye, is_nil(game_id))
    end)
  end

  defp build_filter(params) do
    PlayerStats.Filter.build!(params)
  end

  defp current_filters(filter) do
    filter
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

  defp game_form(%{bye: true} = assigns) do
    ~H"""
    <p class="bg-gray-200 px-2 w-12 text-center">B</p>
    """
  end

  defp game_form(%{min_disposals_difference: min_disposals_difference} = assigns) when min_disposals_difference > 0 do
    ~H"""
    <p class="bg-green-400 px-2 w-12 text-center">+<%= @min_disposals_difference %></p>
    """
  end

  defp game_form(%{min_disposals_difference: min_disposals_difference} = assigns) when min_disposals_difference < 0 do
    ~H"""
    <p class="bg-red-400 px-2 w-12 text-center">-<%= abs(@min_disposals_difference) %></p>
    """
  end

  defp game_form(%{min_disposals_difference: 0} = assigns) do
    ~H"""
    <p class="bg-cyan-400 px-2 w-12 text-center">0</p>
    """
  end

  defp game_form(assigns) do
    ~H"""
    <p class="px-2 w-12 text-center">-</p>
    """
  end
end
