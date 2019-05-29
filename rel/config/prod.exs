# Contains our release context using Distillery 2.0 config providers.
# Not to be confused with production environment configurations
# running out of a release.

use Mix.Config

config :bookclub,
  postmark_server_token: System.get_env("POSTMARK_SERVER_TOKEN"),
  postmark_sender: System.get_env("POSTMARK_SENDER"),
  env: :prod

if System.get_env("K8S_ENV") == "none" do
  config :bookclub, Bookclub.Repo,
    database: System.get_env("POSTGRES_DB"),
    username: System.get_env("POSTGRES_USER"),
    password: System.get_env("POSTGRES_PASSWORD"),
    hostname: System.get_env("POSTGRES_HOST"),
    port: System.get_env("POSTGRES_PORT"),
    pool_size: 10
else
  config :bookclub, Bookclub.Repo,
    database: System.get_env("POSTGRES_DB"),
    username: System.get_env("POSTGRES_USER"),
    password: System.get_env("POSTGRES_PASSWORD"),
    hostname: System.get_env("POSTGRES_HOST"),
    port: System.get_env("POSTGRES_PORT"),
    ssl: true,
    pool_size: 10,
    prepare: :unnamed
end

config :bookclub, BookclubWeb.Endpoint,
  http: [:inet6, port: 4000],
  url: [scheme: "http", host: System.get_env("BOOKCLUB_HOST"), port: 80],
  server: true,
  cache_static_manifest: "priv/static/cache_manifest.json",
  secret_key_base: System.get_env("SECRET_KEY_BASE")

config :bookclub, Bookclub.Auth.Guardian,
  secret_key: System.get_env("GUARDIAN_KEY")

config :bookclub,
  callback_url: System.get_env("BOOKCLUB_CALLBACK_URL")

config :sentry,
  dsn: System.get_env("BOOKCLUB_SENTRY_CODE")

config :ex_twilio,
  account_sid: System.get_env("TWILIO_TEST_ACCOUNT_SID"),
  auth_token: System.get_env("TWILIO_TEST_AUTH_TOKEN")

config :bookclub,
  phone_number: System.get_env("TWILIO_TEST_PHONE_NUMBER")

