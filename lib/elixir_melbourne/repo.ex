defmodule ElixirMelbourne.Repo do
  use Ecto.Repo,
    otp_app: :elixir_melbourne,
    adapter: Ecto.Adapters.Postgres
end
