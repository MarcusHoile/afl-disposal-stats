defmodule PlayerStatsTest do
  use PlayerStats.DataCase

  describe "list_players/1" do
    test "filters players by single team" do
      player_season =
        :player_season
        |> insert()
        |> with_game_player(disposals: 4)
        |> with_game_player(disposals: 3)

      filter = %PlayerStats.Filter{
        current_year: 2021,
        team_ids: [player_season.team_season.team_id]
      }

      assert [
               %{
                 avg_disposals: 3.5,
                 first_name: _,
                 last_name: _,
                 max_disposals: 4,
                 min_disposals: 3
               }
             ] = PlayerStats.list_players(filter)
    end

    test "filters players by min_disposals" do
      player_season =
        :player_season
        |> insert()
        |> with_game_player(disposals: 4)

      filter = %PlayerStats.Filter{
        current_year: 2021,
        min_disposals: 5,
        team_ids: [player_season.team_season.team_id]
      }

      assert [] = PlayerStats.list_players(filter)
    end

    test "ignores players of opposition team" do
      season = insert(:season)
      player_season = insert(:player_season, team_season: build(:team_season, season: season))

      other_player_season = insert(:player_season, team_season: build(:team_season, season: season))

      insert(:game, season: season, teams: [player_season.team_season.team, other_player_season.team_season.team])

      player_season |> with_game_player(disposals: 4)

      other_player_season |> with_game_player(disposals: 3)

      filter = %PlayerStats.Filter{
        current_year: 2021,
        team_ids: [player_season.team_season.team_id]
      }

      assert [
               %{
                 avg_disposals: 4.0,
                 max_disposals: 4,
                 min_disposals: 4
               }
             ] = PlayerStats.list_players(filter)
    end

    test "filters players by two teams" do
      ps1 =
        :player_season
        |> insert()
        |> with_game_player(disposals: 4)

      team_season = build(:team_season, season: ps1.team_season.season)

      ps2 =
        :player_season
        |> insert(team_season: team_season)
        |> with_game_player(disposals: 3)

      filter = %PlayerStats.Filter{
        current_year: 2021,
        team_ids: [ps1.team_season.team_id, ps2.team_season.team_id]
      }

      assert [
               %{
                 avg_disposals: 4.0,
                 max_disposals: 4,
                 min_disposals: 4
               },
               %{
                 avg_disposals: 3.0,
                 max_disposals: 3,
                 min_disposals: 3
               }
             ] = PlayerStats.list_players(filter)
    end

    @tag :skip
    test "empty result, when no team filter" do
    end

    test "filters players by max_avg_disposals" do
      player_season =
        :player_season
        |> insert()
        |> with_game_player(disposals: 4)
        |> with_game_player(disposals: 3)

      filter = %PlayerStats.Filter{
        current_year: 2021,
        max_avg_disposals: 3,
        team_ids: [player_season.team_season.team_id]
      }

      assert [] = PlayerStats.list_players(filter)
    end

    @tag :skip
    test "filters players by team rounds" do
    end
  end
end
