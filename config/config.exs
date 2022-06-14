# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :crawler, root_url: "https://afltables.com/afl/seas/2021.html"

config :player_stats,
  current_year: 2021,
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
  render_errors: [view: PlayerStatsWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: PlayerStats.PubSub,
  live_view: [signing_salt: "yobjdVeK"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :player_stats, PlayerStats.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
