defmodule Core.MixProject do
  use Mix.Project

  def project do
    [
      app: :core,
      version: "1.0.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Core.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:argon2_elixir, "~> 4.0"},
      {:phoenix, "~> 1.7", override: true},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, "~> 0.18.0"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "1.0.0-rc.6", override: true},
      {:floki, "~> 0.36", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.0"},
      {:esbuild, "~> 0.8.0", runtime: Mix.env() == :dev},
      {:swoosh, "~> 1.3"},
      {:finch, "~> 0.18.0"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.24.0"},
      {:jason, "~> 1.2"},
      {:cors_plug, "~> 3.0"},
      {:credo, "~> 1.4", only: :dev, runtime: false},
      {:ecto_psql_extras, "~> 0.8.0"},
      {:inflex, "~> 2.1"},
      {:earmark, "~> 1.4"},
      {:plug_telemetry_server_timing, "~> 0.3.0"},
      {:slugy, "~> 4.1"},
      {:oban, "~> 2.14"},
      {:hackney, "~> 1.18"},
      {:sentry, "~> 10.6"},
      {:timex, "~> 3.7"},
      {:paper_trail, "~> 1.0"},
      {:ueberauth, "~> 0.7"},
      {:ueberauth_twitch, "~> 0.2.0"},
      {:bandit, "~> 1.0"},
      {:ex_machina, "~> 2.7", only: :test},
      {:ecto_function, "~> 1.0"},
      {:ecto_interface, "~> 2.3"},
      {:encrypted_secrets, "~> 0.3.0"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.build"],
      "ecto.setup": ["ecto.create --quiet", "ecto.build"],
      "ecto.seeds": ["run priv/repo/seeds.exs --quiet"],
      "ecto.fixtures": ["run priv/repo/fixtures.exs --quiet"],
      "ecto.build": [
        "ecto.load --quiet",
        "ecto.migrate",
        "ecto.dump",
        "ecto.seeds",
        "ecto.fixtures"
      ],
      "ecto.reload": ["ecto.drop --quiet", "ecto.create --quiet", "ecto.build"],
      "ecto.reset": [
        "ecto.drop --quiet",
        "ecto.create --quiet",
        "ecto.migrate",
        "ecto.dump",
        "ecto.seeds",
        "ecto.fixtures"
      ],
      test: [
        "ecto.drop --quiet",
        "ecto.create --quiet",
        "ecto.load --quiet",
        "ecto.seeds",
        "test"
      ],
      "assets.setup": [
        "esbuild.install --if-missing",
        "cmd --cd assets/ npm install"
      ],
      "assets.build": ["assets.setup", "esbuild default"],
      "assets.deploy": ["esbuild default --minify", "phx.digest"],
      check: ["compile", "credo", "dialyzer --quiet"]
    ]
  end
end
