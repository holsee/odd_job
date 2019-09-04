use Mix.Config

# Configure your database
config :odd_job, OddJob.Repo,
  username: "postgres",
  password: "postgres",
  database: "odd_job_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :odd_job_web, OddJobWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
