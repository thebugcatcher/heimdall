defmodule Heimdall.Repo do
  use Ecto.Repo,
    otp_app: :heimdall,
    adapter: Ecto.Adapters.Postgres
end
