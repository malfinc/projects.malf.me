defmodule Core.MixProject do
  use Mix.Project

  def project do
    [
      name: "Core",
      app: :core,
      version: "1.0.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: [
        plt_add_apps: [:mix],
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Core.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon]
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
      {:bcrypt_elixir, "~> 3.0"},
      {:cors_plug, "~> 3.0"},
      {:credo, "~> 1.4", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:ecto_psql_extras, "~> 0.7.0"},
      {:ecto_sql, "~> 3.7"},
      {:esbuild, "~> 0.5.0", runtime: Mix.env() == :dev},
      {:floki, "~> 0.34.0", only: :test},
      {:gettext, "~> 0.20.0"},
      {:inflex, "~> 2.1"},
      {:jason, "~> 1.2"},
      {:phoenix_ecto, "~> 4.4"},
      {:earmark, "~> 1.4"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_dashboard, "~> 0.7.2"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.18.3"},
      {:phoenix, "~> 1.7.0-rc.0", override: true},
      {:plug_cowboy, "~> 2.5"},
      {:plug_telemetry_server_timing, "~> 0.3.0"},
      {:postgrex, "~> 0.16.0"},
      {:slugy, "~> 4.1.1"},
      {:swoosh, "~> 1.3"},
      {:oban, "~> 2.12"},
      {:telemetry_metrics, "~> 0.6.0"},
      {:telemetry_poller, "~> 1.0"},
      {:hackney, "~> 1.18"},
      {:sentry, "~> 8.0"},
      {:finch, "~> 0.13.0"},
      {:timex, "~> 3.7"},
      {:phx_component_helpers, "~> 1.1"},
      {:estate, "~> 1.0"},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:paper_trail, "~> 0.14.3"}
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
      check: [
        "compile",
        "credo",
        "dialyzer --quiet"
      ],
      setup: ["deps.get", "ecto.setup"],
      "ecto.seeds": ["run priv/repo/seeds.exs --quiet"],
      "ecto.fixtures": ["run priv/repo/fixtures.exs --quiet"],
      "ecto.setup": [
        "ecto.create",
        "ecto.load",
        "ecto.migrate",
        "ecto.dump",
        "ecto.seeds",
        "ecto.fixtures"
      ],
      "ecto.reload": ["ecto.drop", "ecto.setup"],
      "ecto.reset": [
        "ecto.drop --quiet",
        "ecto.create",
        "ecto.migrate",
        "ecto.dump",
        "ecto.seeds",
        "ecto.fixtures"
      ],
      test: [
        "ecto.reload",
        "test"
      ],
      "assets.deploy": ["esbuild default --minify", "phx.digest"]
    ]
  end
end
