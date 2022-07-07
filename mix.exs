defmodule PlayerStats.MixProject do
  use Mix.Project

  def project do
    [
      app: :player_stats,
      version: "0.1.0",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(Mix.env()),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {PlayerStats.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "dev/support", "test/support"]
  defp elixirc_paths(:dev), do: ["lib", "dev/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:crawler, "~> 1.1.1"},
      {:credo, "~> 1.1", only: [:dev, :test], runtime: false},
      {:ecto_sql, "~> 3.6"},
      {:esbuild, "~> 0.4", runtime: Mix.env() == :dev},
      {:ex_machina, "~> 2.7.0"},
      {:floki, ">= 0.30.0"},
      {:gettext, "~> 0.18"},
      {:heroicons, "~> 0.3"},
      {:jason, "~> 1.2"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.17"},
      {:phoenix, "~> 1.6"},
      {:plug_cowboy, "~> 2.5"},
      {:swoosh, "~> 1.3"},
      {:tailwind, "~> 0.1", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:timex, "~> 3.7"}
    ]
  end

  defp aliases(:test) do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end

  defp aliases(_) do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.deploy": [
        "esbuild default --minify",
        "tailwind default --minify",
        "phx.digest"
      ]
    ]
  end
end
