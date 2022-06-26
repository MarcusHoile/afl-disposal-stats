defmodule PlayerStatsTest do
  use PlayerStats.DataCase

  describe "list_players/1" do
    test "filters players by single team" do
      season = insert(:season)

      player_season =
        :player_season
        |> insert(team_season: build(:team_season, season: season))
        |> with_game_player(disposals: 4)

      # add game the player did not play in
      insert(:game, season: season, teams: [player_season.team_season.team])

      filter = %PlayerStats.Filter{
        current_year: 2021,
        team_ids: [player_season.team_season.team_id]
      }

      assert [
               %PlayerStats.Schema.PlayerSeason{
                 game_players: [
                   %PlayerStats.Schema.GamePlayer{disposals: 4, game_id: _, goals: 0, handballs: 0, kicks: 0}
                 ],
                 player: %PlayerStats.Schema.Player{},
                 team_season: %{team: %PlayerStats.Schema.Team{}}
               }
             ] = PlayerStats.list_players(filter)
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
               %PlayerStats.Schema.PlayerSeason{
                 game_players: [%PlayerStats.Schema.GamePlayer{disposals: 4}],
                 player: %PlayerStats.Schema.Player{},
                 team_season: %{team: %PlayerStats.Schema.Team{}}
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
               %PlayerStats.Schema.PlayerSeason{
                 game_players: [%PlayerStats.Schema.GamePlayer{}],
                 player: %PlayerStats.Schema.Player{},
                 team_season: %{team: %PlayerStats.Schema.Team{}}
               },
               %PlayerStats.Schema.PlayerSeason{
                 game_players: [%PlayerStats.Schema.GamePlayer{}],
                 player: %PlayerStats.Schema.Player{},
                 team_season: %{team: %PlayerStats.Schema.Team{}}
               }
             ] = PlayerStats.list_players(filter)
    end

    test "empty result, when no team filter" do
      filter = %PlayerStats.Filter{
        current_year: 2021,
        team_ids: []
      }

      assert [] = PlayerStats.list_players(filter)
    end
  end
end
