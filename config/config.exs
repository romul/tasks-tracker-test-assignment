# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :tasks_tracker,
  ecto_repos: [TasksTracker.Repo]

# Configures the endpoint
config :tasks_tracker, TasksTrackerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "yWfs/aEpSAauEeH4Yd9BdZbr2Xhlp82hvcMhcKqPQyRbZ2H9uvc/o+HKulIkyMAz",
  render_errors: [view: TasksTrackerWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: TasksTracker.PubSub,
  live_view: [signing_salt: "EiQ1IGml"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
