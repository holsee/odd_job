# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

# Configure Mix tasks and generators
config :odd_job,
  ecto_repos: [OddJob.Repo]

config :odd_job_web,
  ecto_repos: [OddJob.Repo],
  generators: [context_app: :odd_job]

# Configures the endpoint
config :odd_job_web, OddJobWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "4sYU1GRYGKjl9Hr1H02tIKaV0qy83TmAQbm3qA/uX0Scz5G1A2qYNY+FNxwQ/G7i",
  render_errors: [view: OddJobWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: OddJobWeb.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ueberauth, Ueberauth,
  base_path: "/api/auth",
  providers: [
    identity:
      {Ueberauth.Strategy.Identity,
       [
         callback_methods: ["POST"],
         nickname_field: :username,
         param_nesting: "user",
         uid_field: :username
       ]}
  ]

config :odd_job_web, OddJobWeb.Guardian,
  issuer: "OddJob",
  secret_key: "qD0N0VNGSI4Q8hIhZVrVdUJeqYTPFHpen8tUVSO6I4wmV5VHdc7M7KLd8+crzVnx",
  permissions: %{
    default: [:read_users, :write_users]
  }

# Configure the authentication plug pipeline
config :odd_job_web, OddJobWeb.Plug.AuthAccessPipeline,
  module: OddJobWeb.Guardian,
  error_handler: OddJobWeb.Plug.AuthErrorHandler

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
