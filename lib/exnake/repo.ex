defmodule Exnake.Repo do
  use Ecto.Repo,
    otp_app: :exnake,
    adapter: Ecto.Adapters.Postgres
end
