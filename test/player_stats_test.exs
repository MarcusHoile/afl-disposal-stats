defmodule PlayerStatsTest do
  use PlayerStats.DataCase
  alias PlayerStats.Schema.{GamePlayer, Player}

  describe "list_players/1" do
    test "filters players by single team" do
      player_season =
        :player_season
        |> insert()
        |> with_game_player(handballs: 4)
        |> with_game_player(kicks: 3)

      filter = %PlayerStats.Filter{
        current_year: 2021,
        team_ids: [player_season.team_season.team_id]
      }

      assert [
               %Player{
                 game_players: [
                   %GamePlayer{
                     disposals: 0,
                     goals: 0,
                     handballs: 0,
                     kicks: 3
                   },
                   %GamePlayer{
                     disposals: 0,
                     goals: 0,
                     handballs: 4,
                     kicks: 0
                   }
                 ]
               }
             ] = PlayerStats.list_players(filter)
    end

    test "filters players by two teams" do
      ps1 =
        :player_season
        |> insert()
        |> with_game_player(handballs: 4)

      team_season = build(:team_season, season: ps1.team_season.season)

      ps2 =
        :player_season
        |> insert(team_season: team_season)
        |> with_game_player(kicks: 3)

      filter = %PlayerStats.Filter{
        current_year: 2021,
        team_ids: [ps1.team_season.team_id, ps2.team_season.team_id]
      }

      assert [
               %Player{
                 game_players: [
                   %GamePlayer{
                     disposals: 0,
                     goals: 0,
                     handballs: 4,
                     kicks: 0
                   }
                 ]
               },
               %Player{
                 game_players: [
                   %GamePlayer{
                     disposals: 0,
                     goals: 0,
                     handballs: 0,
                     kicks: 3
                   }
                 ]
               }
             ] = PlayerStats.list_players(filter)
    end

    @tag :skip
    test "error, when no team filter" do
    end

    @tag :skip
    test "filters players by min_disposals" do
    end

    @tag :skip
    test "filters players by max_avg_disposals" do
    end

    @tag :skip
    test "filters players by team rounds" do
    end
  end
end
