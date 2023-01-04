# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :core,
  ecto_repos: [Core.Repo],
  generators: [binary_id: true],
  application_name: "Michael Al Fox",
  support_email_address: "support@www.malf.me",
  theme_color: "#ffffff",
  description: "A website",
  short_description: "A website",
  google_site_verification: "",
  google_tag_manager_id: ""

config :core, :twitch, webhook_path: "twitch/webhooks"

config :core,
       Core.Repo,
       migration_primary_key: [name: :id, type: :binary_id],
       migration_foreign_key: [column: :id, type: :binary_id]

# Configures the endpoint
config :core, CoreWeb.Endpoint,
  url: [host: Application.get_env(:core, :domain)],
  render_errors: [
    formats: [html: CoreWeb.ErrorHTML, json: CoreWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Core.PubSub,
  live_view: [signing_salt: "JKEx/AEF"]

config :ueberauth, Ueberauth,
  providers: [
    twitch: {Ueberauth.Strategy.Twitch, [default_scope: "user:read:email"]}
  ]

# Configure papertrail to use the right repository
config :paper_trail,
  repo: Core.Repo,
  item_type: Ecto.UUID,
  originator: [name: :accounts, model: Core.Users.Account],
  originator_type: Ecto.UUID,
  originator_relationship_options: [references: :uuid]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :core, Core.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.41",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
import IO

config :logger, :console,
  format: "$time $metadata[$level] #{IO.ANSI.bright()}$message#{IO.ANSI.normal()}\n",
  metadata: [:request_id],
  color: :enabled

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure Sentry, the service we use to alert us to issues in the application
config :sentry,
  environment_name: Mix.env(),
  included_environments: [:prod]

config :core, Oban,
  repo: Core.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [default: 10]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
