defmodule OddJob.Repo do
  use Ecto.Repo,
    otp_app: :odd_job,
    adapter: Ecto.Adapters.Postgres
end
