defmodule PlayerStats.Seeds do
  def insert! do
    insert_teams!()
  end

  defp insert_teams! do
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
