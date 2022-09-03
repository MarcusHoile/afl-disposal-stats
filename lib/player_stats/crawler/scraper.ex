defmodule PlayerStats.Crawler.Scraper do
  @moduledoc """
  Scrapers be scraping
  """
  @behaviour Crawler.Scraper.Spec
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]
  require Logger
  alias Crawler.Store.Page
  alias PlayerStats.{Repo, Schema}

  def rescrape(season) do
    Schema.Season |> Repo.get_by(year: season) |> Repo.delete()

    Schema.Page
    |> Repo.all()
    |> Enum.each(fn %{url: url, path: path} ->
      body =
        "#{File.cwd!()}/../../Documents/player-stats/afltables.com#{path}"
        |> Path.expand()
        |> File.read!()

      scrape(%Page{url: url, body: body})
    end)
  end

  # credo:disable-for-next-line Credo.Check.Refactor.ABCSize
  def scrape(%Page{url: "https://afltables.com/afl/stats/games/" <> _ = url, body: body, opts: _opts} = page) do
    {:ok, html} = Floki.parse_document(body)

    with current_year <- get_current_year(url),
         {:ok, db_page} <- find_or_create_page(url),
         {:ok, team_season_a} <- find_or_create_team_season(html, current_year, 1),
         {:ok, team_season_b} <- find_or_create_team_season(html, current_year, 2),
         {:ok, game} <- find_or_create_game(html, current_year, url),
         {:ok, game} <- save_game_teams(game, team_season_a, team_season_b),
         [table_a, table_b] <- find_team_tables(html),
         :ok <- save_team_data(table_a, %{team_season: team_season_a, game: game}),
         :ok <- save_team_data(table_b, %{team_season: team_season_b, game: game}),
         {:ok, _db_page} <- mark_page_scraped(db_page) do
      {:ok, page}
    else
      wtf ->
        Logger.error(wtf: wtf)
        {:ok, page}
    end
  end

  def scrape(page) do
    {:ok, page}
  end

  defp get_current_year("https://afltables.com/afl/stats/games/" <> path) do
    path
    |> String.split("/")
    |> List.first()
    |> String.to_integer()
  end

  defp save_team_data(team_table, %{team_season: team_season, game: game}) do
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
         {:ok, player_season} <- find_or_create_player_season(player_data, team_season) do
      create_or_update_game_player(game, player_season, player_data)
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
      preload: :player,
      where: ps.team_season_id == ^team_season_id,
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
      |> Floki.text()
    end)
    |> Enum.map(&Map.get(legend(), &1))
  end

  defp legend do
    Application.get_env(:player_stats, :legend)
  end

  defp find_season(current_year) do
    PlayerStats.Schema.Season
    |> PlayerStats.Repo.get_by(year: current_year)
    |> case do
      nil ->
        PlayerStats.Repo.insert!(%PlayerStats.Schema.Season{year: current_year})

      season ->
        season
    end
  end

  defp find_or_create_team_season(html, current_year, n) do
    team_name =
      html
      |> Floki.find("table:first-of-type")
      |> Floki.find("tr:nth-child(#{n + 1}) td:first-of-type")
      |> Floki.find("a")
      |> Floki.text()

    from(t in PlayerStats.Schema.Team,
      where: like(t.name, ^"#{team_name}%"),
      preload: [team_seasons: ^team_seasons_query(current_year)],
      limit: 1
    )
    |> PlayerStats.Repo.one()
    |> case do
      %{team_seasons: [team_season]} ->
        {:ok, team_season}

      %{id: team_id} ->
        %PlayerStats.Schema.TeamSeason{team_id: team_id, season_id: find_season(current_year).id}
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
      on: ps.id == ^player_season_id,
      where: gp.game_id == ^game_id,
      where: gp.player_id == ^player_id
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
  end

  # TODO figure out how to find player, prolly need to scrape more players details eg DOB
  # for now just create the player
  defp find_or_create_player(%{"player_name" => player_name}, _team_season) do
    [last_name, first_name] = String.split(player_name, ", ")

    %PlayerStats.Schema.Player{}
    |> PlayerStats.Schema.Player.changeset(%{first_name: first_name, last_name: last_name})
    |> PlayerStats.Repo.insert!()
  end

  defp create_player_season(%{id: player_id}, %{id: team_season_id}, player_data) do
    %PlayerStats.Schema.PlayerSeason{player_id: player_id}
    |> change(team_season_id: team_season_id)
    |> PlayerStats.Schema.PlayerSeason.changeset(player_data)
    |> PlayerStats.Repo.insert()
  end

  defp team_seasons_query(current_year) do
    from(ts in PlayerStats.Schema.TeamSeason,
      join: s in assoc(ts, :season),
      on: s.year == ^current_year
    )
  end

  defp find_or_create_game(html, current_year, url) do
    page_id =
      url
      |> String.split("/#{current_year}/")
      |> List.last()

    %{"game_id" => game_id} = Regex.named_captures(~r/(?<game_id>\d+)/, page_id)

    PlayerStats.Schema.Game
    |> PlayerStats.Repo.get_by(external_id: game_id)
    |> case do
      nil ->
        round_title = find_round(html)

        %PlayerStats.Schema.Game{}
        |> PlayerStats.Schema.Game.changeset(%{
          external_id: game_id,
          played_at: find_played_at(html),
          round: round_number(round_title),
          round_title: round_title,
          season_id: find_season(current_year).id
        })
        |> PlayerStats.Repo.insert()

      game ->
        {:ok, game}
    end
  end

  defp find_played_at(html) do
    # eg "Round: 1 Venue: DocklandsDate: Fri, 18-Mar-2022 7:50 PM (6:50 PM) Attendance: 40129"
    row =
      html
      |> Floki.find("table:first-of-type")
      |> Floki.find("tr:first-of-type td:nth-child(2)")
      |> Floki.text()

    %{"played_at" => played_at} = Regex.named_captures(~r/Date:\s.*,\s(?<played_at>.*?(?=\s\(|\sA))/, row)

    date_format = "%d-%b-%Y %l:%M %p"

    played_at
    |> Timex.parse(date_format, :strftime)
    |> case do
      {:error, _} ->
        ("0" <> played_at)
        |> Timex.parse!(date_format, :strftime)

      {:ok, datetime} ->
        datetime
    end
    |> DateTime.from_naive!("Australia/Sydney")
  end

  defp round_number(round_title) do
    ~r/[0-9]+/
    |> Regex.scan(round_title)
    |> case do
      [] -> nil
      [[round]] -> String.to_integer(round)
    end
  end

  defp find_round(html) do
    row = html |> Floki.find("table:first-of-type") |> Floki.find("tr:first-of-type td:nth-child(2)") |> Floki.text()

    %{"round" => round} = Regex.named_captures(~r/(?<=Round: )(?<round>.+)Venue/, row)

    String.trim(round)
  end

  defp find_or_create_page(url) do
    Schema.Page
    |> Repo.get_by(url: url)
    |> case do
      nil ->
        %{path: path} = URI.parse(url)

        %Schema.Page{scraped: false, path: path, url: url}
        |> Repo.insert()

      page ->
        {:ok, page}
    end
  end

  defp mark_page_scraped(db_page) do
    db_page
    |> change(scraped: true)
    |> Repo.update()
  end

  defp find_team_tables(html) do
    html
    |> Floki.find("center > table")
    |> Enum.filter(fn table ->
      table
      |> Floki.find("thead")
      |> Floki.text()
      |> String.contains?("Match Statistics")
    end)
  end

  defp save_game_teams(game, team_season_a, team_season_b) do
    teams =
      from(t in Schema.Team, where: t.id in ^[team_season_a.team_id, team_season_b.team_id])
      |> Repo.all()

    game
    |> Repo.preload(:teams)
    |> change()
    |> Ecto.Changeset.put_assoc(:teams, teams)
    |> Repo.update()
  end
end
