defmodule TasksTracker.Repo do
  use Ecto.Repo,
    otp_app: :tasks_tracker,
    adapter: Ecto.Adapters.Postgres
end
