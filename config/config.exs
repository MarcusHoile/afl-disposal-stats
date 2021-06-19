# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :chartkick, json_serializer: Jason

config :crawler, root_url: "https://afltables.com/afl/seas/2021.html"

config :player_stats,
  ecto_repos: [PlayerStats.Repo],
  legend: %{
    "#" => "guernsey_number",
    "Player" => "player_name",
    "KI" => "kicks",
    "MK" => "marks",
    "HB" => "handballs",
    "DI" => "disposals",
    "GL" => "goals",
    "BH" => "behinds",
    "HO" => "hitouts",
    "TK" => "tackles",
    "RB" => "rebound_50s",
    "IF" => "inside_50s",
    "CL" => "clearances",
    "CG" => "clangers",
    "FF" => "free_kicks_for",
    "FA" => "free_kicks_against",
    "BR" => "brownlow_votes",
    "CP" => "contested_possessions",
    "UP" => "uncontested_possessions",
    "CM" => "contested_marks",
    "MI" => "marks_inside_50",
    "1%" => "one_percenters",
    "BO" => "bounces",
    "GA" => "goal_assists",
    "%P" => "percentage_of_game_playes"
  }

# Configures the endpoint
config :player_stats, PlayerStatsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "SD9WqdoqNCSMgQD+M7o0p5/um1MZZjy6lEl4voQVXxHNe0Mjd96ZSjeXR2w9oco7",
  render_errors: [view: PlayerStatsWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: PlayerStats.PubSub,
  live_view: [signing_salt: "yI9hNkqZ"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
