use Mix.Config

config :bookclub,
  env: :test

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :bookclub, BookclubWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :bookclub, Bookclub.Repo, pool: Ecto.Adapters.SQL.Sandbox

config :bookclub, :environment, :test
