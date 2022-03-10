defmodule ElixirMelbourne.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      ElixirMelbourne.Repo,
      # Start the Telemetry supervisor
      ElixirMelbourneWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: ElixirMelbourne.PubSub},
      # Start the Endpoint (http/https)
      ElixirMelbourneWeb.Endpoint
      # Start a worker by calling: ElixirMelbourne.Worker.start_link(arg)
      # {ElixirMelbourne.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElixirMelbourne.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ElixirMelbourneWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
