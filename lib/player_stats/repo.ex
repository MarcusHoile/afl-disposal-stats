defmodule PlayerStats.Repo do
  use Ecto.Repo,
    otp_app: :player_stats,
    adapter: Ecto.Adapters.Postgres
end
