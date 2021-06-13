defmodule PlayerStats.Crawler.Scraper do
  @behaviour Crawler.Scraper.Spec
  alias Crawler.Store.Page
  import Ecto.Query, only: [from: 2]
  import Ecto.Changeset
  alias PlayerStats.{Repo, Schema}

  def scrape(%Page{url: url, body: body, opts: _opts} = page) do
    {:ok, html} = Floki.parse_document(body)

    with {:ok, _page} <- find_or_create_page(url),
         {:ok, team_season_a} <- find_or_create_team_season(html, 1),
         {:ok, team_season_b} <- find_or_create_team_season(html, 2),
         {:ok, game} <- find_or_create_game(html, url),
         :ok <-
           save_team_data(html, "#sortableTable0", %{team_season: team_season_a, game: game}),
         :ok <- save_team_data(html, "#sortableTable1", %{team_season: team_season_b, game: game}) do
      {:ok, page}
    else
      _wtf ->
        {:ok, page}
    end
  end

  defp save_team_data(html, selector, %{team_season: team_season, game: game}) do
    team_table = Floki.find(html, selector)
    header = header_row(team_table)

    1..23
    |> Enum.map(&scrape_game_player_data(team_table, header, team_season, game, &1))
    |> Enum.all?(fn
      {:ok, _} ->
        true

      _ ->
        false
    end)
    |> case do
      true ->
        :ok

      _ ->
        :error
    end
  end

  defp scrape_game_player_data(table, header, team_season, game, n) do
    with player_data <- find_player_data(table, n, header),
         {:ok, player_season} <- find_or_create_player_season(player_data, team_season),
         {:ok, game_player} <- create_or_update_game_player(game, player_season, player_data) do
      {:ok, game_player}
    end
  end

  defp to_map(player_data, header) do
    header
    |> Enum.zip(player_data)
    |> Enum.into(%{})
  end

  defp find_or_create_player_season(
         %{"guernsey_number" => number} = player_data,
         %{id: team_season_id} = team_season
       ) do
    from(ps in PlayerStats.Schema.PlayerSeason,
      join: ts in assoc(ps, :team_season),
      on: ts.id == ^team_season_id,
      preload: :player,
      where: ps.guernsey_number == ^number
    )
    |> PlayerStats.Repo.one()
    |> case do
      nil ->
        player_data
        |> find_or_create_player(team_season)
        |> create_player_season(team_season, player_data)

      player_season ->
        {:ok, player_season}
    end
  end

  defp find_player_data(team_table, n, header) do
    team_table
    |> Floki.find("tbody tr:nth-child(#{n})")
    |> List.first()
    |> Floki.children()
    |> Enum.map(fn node ->
      node
      |> Floki.find("a")
      |> case do
        [] ->
          Floki.text(node)

        result ->
          result
          |> Floki.text()
      end
    end)
    |> Enum.map(&String.replace(&1, ~r/[^\da-zA-Z,\s]/, ""))
    |> Enum.map(&String.trim/1)
    |> to_map(header)
  end

  defp header_row(table) do
    table
    |> Floki.find("thead tr:nth-last-child(1)")
    |> List.first()
    |> Floki.children()
    |> Enum.map(fn node ->
      node
      |> Floki.find("a")
      |> Floki.text()
    end)
    |> Enum.map(&Map.get(legend(), &1))
  end

  defp legend do
    Application.get_env(:player_stats, :legend)
  end

  defp find_season do
    PlayerStats.Schema.Season
    |> PlayerStats.Repo.get_by(year: current_year())
    |> case do
      nil ->
        PlayerStats.Repo.insert!(%PlayerStats.Schema.Season{year: current_year()})

      season ->
        season
    end
  end

  defp find_or_create_team_season(html, n) do
    team_name =
      html
      |> Floki.find("table:first-of-type")
      |> Floki.find("tr:nth-child(#{n + 1}) td:first-of-type")
      |> Floki.find("a")
      |> Floki.text()

    from(t in PlayerStats.Schema.Team,
      where: like(t.name, ^"%#{team_name}%"),
      preload: [team_seasons: ^team_seasons_query()],
      limit: 1
    )
    |> PlayerStats.Repo.one()
    |> case do
      %{team_seasons: [team_season]} ->
        {:ok, team_season}

      %{id: team_id} ->
        %PlayerStats.Schema.TeamSeason{team_id: team_id, season_id: find_season().id}
        |> PlayerStats.Repo.insert()
    end
  end

  defp create_or_update_game_player(
         %{id: game_id},
         %{id: player_season_id, player_id: player_id},
         player_data
       ) do
    from(gp in PlayerStats.Schema.GamePlayer,
      join: ps in assoc(gp, :player_season),
      on: ps.id == ^player_season_id
    )
    |> PlayerStats.Repo.one()
    |> case do
      nil ->
        %PlayerStats.Schema.GamePlayer{}
        |> change(%{
          game_id: game_id,
          player_id: player_id,
          player_season_id: player_season_id
        })
        |> PlayerStats.Schema.GamePlayer.changeset(player_data)
        |> change(stats: player_data)

      game_player ->
        game_player
        |> PlayerStats.Schema.GamePlayer.changeset(player_data)
    end
    |> PlayerStats.Repo.insert_or_update()

    # player_data
    # |> Map.take(~w(guernsey_number player_name kicks handballs marks disposals goals b))
  end

  # TODO figure out how to find player, prolly need to scrape more players details eg DOB
  # for now just create the player
  defp find_or_create_player(%{"player_name" => player_name}, _team_season) do
    [last_name, first_name] = String.split(player_name, ", ")

    %PlayerStats.Schema.Player{}
    |> PlayerStats.Schema.Player.changeset(%{first_name: first_name, last_name: last_name})
    |> PlayerStats.Repo.insert!()
  end

  defp create_player_season(%{id: player_id}, %{id: team_season_id} = team_season, player_data) do
    %PlayerStats.Schema.PlayerSeason{player_id: player_id}
    |> change(Map.take(team_season, [:team_id, :season_id]))
    |> change(team_season_id: team_season_id)
    |> PlayerStats.Schema.PlayerSeason.changeset(player_data)
    |> PlayerStats.Repo.insert()
  end

  defp team_seasons_query do
    from(ts in PlayerStats.Schema.TeamSeason,
      join: s in assoc(ts, :season),
      on: s.year == ^current_year()
    )
  end

  defp find_or_create_game(html, url) do
    page_id =
      url
      |> String.split(current_year_as_string())
      |> List.last()

    %{"game_id" => game_id} = Regex.named_captures(~r/(?<game_id>\d+)/, page_id)

    PlayerStats.Schema.Game
    |> PlayerStats.Repo.get_by(external_id: game_id)
    |> case do
      nil ->
        %PlayerStats.Schema.Game{}
        |> PlayerStats.Schema.Game.changeset(%{external_id: game_id, round: find_round(html)})
        |> PlayerStats.Repo.insert()

      game ->
        {:ok, game}
    end
  end

  defp current_year do
    Date.utc_today().year()
  end

  defp current_year_as_string do
    current_year()
    |> Integer.to_string()
  end

  defp find_round(html) do
    row =
      html
      |> Floki.find("table:first-of-type")
      |> Floki.find("tr:first-of-type td:nth-child(2)")
      |> Floki.text()

    %{"round" => round} = Regex.named_captures(~r/(?<=Round: )(?<round>\d+)/, row)

    String.to_integer(round)
  end

  defp find_or_create_page(url) do
    Schema.Page
    |> Repo.get_by(url: url)
    |> case do
      nil ->
        %Schema.Page{url: url}
        |> Repo.insert()

      page ->
        {:ok, page}
    end
  end
end