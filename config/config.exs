# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :exnake,
  ecto_repos: [Exnake.Repo]

# Configures the endpoint
config :exnake, Exnake.Endpoint,
  http: [port: 4000, ip: {0, 0, 0, 0}],
  secret_key_base: "9zl5Zv3PHmKC21uF5rEYksH3FlMyNtUeooaDO3LA7s8/3WH7LRB8FzNDnsEoM0cb",
  render_errors: [view: Exnake.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Exnake.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
