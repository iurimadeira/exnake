# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# config :exnake, ecto_repos: [Exnake.Repo]

# Configures the endpoint
config :exnake, ExnakeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "y7xBMlO7DfnK1X7UcfQ0vtKRAlMCsBOPi0xKLC5chLji2PrqEHuv6SaIhMa9TIxR",
  render_errors: [view: ExnakeWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Exnake.PubSub,
  live_view: [signing_salt: "ZmT/fJxX"],
  http: [port: 12345, compress: true]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
