defmodule PlayerStatsWeb.PlayerStatLive.Index do
  @moduledoc false
  use PlayerStatsWeb, :live_view

  @impl true
  def mount(params, _session, socket) do
    socket =
      socket
      |> assign(:teams, PlayerStats.teams())
      |> assign(:filter, build_filter(default_filter(), params))
      |> assign_previous_rounds()
      |> load_stats()

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, %{assigns: %{filter: filter}} = socket) do
    params = Map.put_new_lazy(params, "team_ids", fn -> [] end)

    socket =
      socket
      |> assign(:filter, build_filter(filter, params))
      |> load_stats()

    {:noreply, socket}
  end

  defp assign_previous_rounds(%{assigns: %{filter: filter}} = socket) do
    socket
    |> assign(:previous_rounds, PlayerStats.previous_rounds(filter))
  end

  defp load_stats(%{assigns: %{filter: filter, previous_rounds: previous_rounds}} = socket) do
    data = %{games: team_games(filter), previous_rounds: previous_rounds}

    stats =
      filter
      |> PlayerStats.list_players()
      |> Enum.map(&build_player_stat_row(&1, data, filter))
      |> maybe_filter_by_streak(filter)
      |> Enum.sort_by(& &1.streak, :desc)

    assign(socket, :stats, stats)
  end

  defp maybe_filter_by_streak(data, %{filter_by_streak: true, min_streak: min_streak}) do
    Enum.filter(data, &(&1.streak >= min_streak))
  end

  defp maybe_filter_by_streak(data, _filter), do: data

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
           guernsey_number: guernsey_number,
           player: %{first_name: first_name, id: player_id, last_name: last_name},
           team_season: %{team: %{id: team_id, name: team_name}}
         },
         game_data,
         filter
       ) do
    disposals = Enum.map(game_players, & &1.disposals)
    game_data = Map.merge(game_data, %{game_players: game_players, team_id: team_id})
    form_data = player_form(game_data, filter)

    %{
      avg_disposals: avg_disposals(disposals, game_players),
      first_name: first_name,
      form: form_data,
      guernsey_number: guernsey_number,
      last_name: last_name,
      max_disposals: Enum.max(disposals),
      min_disposals: Enum.min(disposals),
      name: "#{String.first(first_name)}. #{last_name}",
      player_id: player_id,
      streak: streak(form_data),
      team_name: team_name
    }
  end

  defp avg_disposals(disposals, game_players) do
    Enum.sum(disposals) / Enum.count(game_players)
  end

  defp streak(form) do
    Enum.reduce_while(form, 0, fn
      %{bye: true}, acc -> {:cont, acc}
      %{played: false, bye: false}, acc -> {:halt, acc}
      %{played: true, stat_target_difference: difference}, acc when difference < 0 -> {:halt, acc}
      _, acc -> {:cont, acc + 1}
    end)
  end

  defp player_form(
         %{
           games: games,
           game_players: game_players,
           previous_rounds: previous_rounds,
           team_id: team_id
         },
         filter
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

        game_player ->
          %{
            played: true,
            stat_target_difference: stat_target_difference(game_player, filter)
          }
      end
      |> Map.put(:round, round)
      |> Map.put(:bye, is_nil(game_id))
    end)
  end

  defp build_filter(filter, params) do
    PlayerStats.Filter.build!(filter, params)
  end

  def filter_value(value) when is_list(value) do
    Enum.join(value, ",")
  end

  def filter_value(value), do: value

  defp current_params(filter), do: Map.from_struct(filter)

  defp merge_team_params(%{team_ids: [_, _]} = filter, team) do
    filter
    |> Map.put(:team_ids, [team.id])
    |> current_params()
  end

  defp merge_team_params(%{team_ids: team_ids} = filter, team) do
    filter
    |> Map.put(:team_ids, Enum.uniq([team.id | team_ids]))
    |> current_params()
  end

  defp default_filter do
    %PlayerStats.Filter{
      current_year: default_year(),
      min_disposals: 15
    }
  end

  defp default_year do
    Application.get_env(:player_stats, :current_year, Date.utc_today().year())
  end

  defp game_form(%{bye: true} = assigns) do
    ~H"""
    <p class="bg-gray-200 game-form-table-cell">B</p>
    """
  end

  defp game_form(%{stat_target_difference: stat_target_difference} = assigns) when stat_target_difference > 0 do
    ~H"""
    <p class="bg-green-400 game-form-table-cell">+<%= @stat_target_difference %></p>
    """
  end

  defp game_form(%{stat_target_difference: stat_target_difference} = assigns) when stat_target_difference < 0 do
    ~H"""
    <p class="bg-red-400 game-form-table-cell">-<%= abs(@stat_target_difference) %></p>
    """
  end

  defp game_form(%{stat_target_difference: 0} = assigns) do
    ~H"""
    <p class="bg-cyan-300 game-form-table-cell">0</p>
    """
  end

  defp game_form(assigns) do
    ~H"""
    <p class="game-form-table-cell">-</p>
    """
  end

  defp target_disposal_css(%{min_disposals: min_disposals}, min_disposals), do: "bg-blue-400 text-white"
  defp target_disposal_css(_, _), do: ""

  defp target_goal_css(%{min_goals: min_goals}, min_goals), do: "bg-blue-400 text-white"
  defp target_goal_css(_, _), do: ""

  defp team_logo_filter_css(team, %{team_ids: team_ids}) do
    selected = if Enum.any?(team_ids, &(&1 == team.id)), do: "selected", else: ""
    "filter-logo filter-logo--#{dasherize(team.name)} " <> selected
  end

  defp dasherize(name) do
    name
    |> String.downcase()
    |> String.replace(" ", "-")
  end

  defp stat_target_difference(%{goals: goals}, %{min_goals: min_goals}) when min_goals > 0 do
    goals - min_goals
  end

  defp stat_target_difference(%{disposals: disposals}, %{min_disposals: min_disposals}) do
    disposals - min_disposals
  end

  defp sorting_icon(%{sort_by: column, sort_direction: "asc"}, column) do
    Heroicons.Solid.chevron_up(class: "w-3 h-3 text-blue-400")
  end

  defp sorting_icon(%{sort_by: column, sort_direction: "desc"}, column) do
    Heroicons.Solid.chevron_down(class: "w-3 h-3 text-blue-400")
  end

  defp sorting_icon(_filter, _column) do
    Heroicons.Solid.chevron_down(class: "w-3 h-3")
  end

  defp sort_direction(%{sort_by: column} = filter, column), do: toggle_sort_direction(filter)
  defp sort_direction(_filter, _column), do: "desc"

  defp toggle_sort_direction(%{sort_direction: "asc"}), do: "desc"
  defp toggle_sort_direction(_), do: "asc"

  defp show_disposal_columns?(%{min_goals: 0}), do: true
  defp show_disposal_columns?(_filter), do: false

  # disposal columns
  defp table_columns(%{min_goals: 0}) do
    ~w(guernsey_number name avg min max)
  end

  # goal columns
  defp table_columns(_) do
    ~w(guernsey_number name)
  end

  defp column_label("guernsey_number"), do: "#"
  defp column_label(column), do: String.capitalize(column)
end
