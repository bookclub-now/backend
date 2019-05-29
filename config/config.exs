# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :bookclub,
  ecto_repos: [Bookclub.Repo],
  postmark_server_token: System.get_env("POSTMARK_SERVER_TOKEN"),
  postmark_sender: System.get_env("POSTMARK_SENDER")

config :bookclub, Bookclub.Repo,
  database: System.get_env("POSTGRES_DB"),
  username: System.get_env("POSTGRES_USER"),
  password: System.get_env("POSTGRES_PASSWORD"),
  hostname: System.get_env("POSTGRES_HOST"),
  port: System.get_env("POSTGRES_PORT"),
  pool_size: 10

# Configures the endpoint
config :bookclub, BookclubWeb.Endpoint,
  url: [host: System.get_env("BOOKCLUB_HOST")],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  render_errors: [view: BookclubWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Bookclub.PubSub, adapter: Phoenix.PubSub.PG2]

config :bookclub, Bookclub.Auth.Guardian,
  issuer: "bookclub",
  secret_key: System.get_env("GUARDIAN_KEY"),
  token_ttl: %{"magic" => {20, :minutes}, "access" => {180, :days}},
  ttl: {1, :day}

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
