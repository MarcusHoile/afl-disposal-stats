defmodule PlayerStatsTest do
  use PlayerStats.DataCase
  alias PlayerStats.Schema.{GamePlayer, Player}

  describe "list_players/1" do
    test "filters players by team" do
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
                     handballs: 4,
                     kicks: 0
                   },
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
