[
  import_deps: [:ecto, :ecto_sql, :phoenix],
  subdirectories: ["priv/*/migrations"],
  plugins: [Phoenix.LiveView.HTMLFormatter],
  inputs:
    [
      "*.{heex,ex,exs}",
      "{config,lib,test}/**/*.{heex,ex,exs}",
      "priv/*/fixtures.exs",
      "priv/*/seeds.exs"
    ]
    |> Enum.flat_map(&Path.wildcard(&1, match_dot: true))
    |> Kernel.--([
      "lib/core_web/controllers/lib/core_web/controllers/error/404.html.heex",
      "lib/core_web/controllers/lib/core_web/controllers/error/500.html.heex"
    ]),
  heex_line_length: 1000
]
