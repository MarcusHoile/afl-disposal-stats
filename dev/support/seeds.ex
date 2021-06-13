defmodule PlayerStats.Seeds do
  def insert! do
    insert_teams!()
    insert_season!()

  end

  defp insert_season! do
    PlayerStats.Repo.insert!(%PlayerStats.Schema.Season{year: 2021})
  end

  def insert_teams! do
    teams = [
      "Adelaide Crows",
      "Brisbane Lions",
      "Carlton Blues",
      "Collingwood Magpies",
      "Essendon Bombers",
      "Fremantle Dockers",
      "Geelong Cats",
      "Gold Coast Suns",
      "GWS Giants",
      "Hawthorn Hawks",
      "Melbourne Demons",
      "North Melbourne Kangaroos",
      "Port Adelaide Power",
      "Richmond Tigers",
      "St Kilda Saints",
      "Sydney Swans",
      "West Coast Eagles",
      "Western Bulldogs"
    ]

    teams
    |> Enum.each(&PlayerStats.Repo.insert!(%PlayerStats.Schema.Team{name: &1}))
  end
end
