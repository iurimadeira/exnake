defmodule Exnake.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  import Supervisor.Spec

  def start(_type, _args) do
    children = [
      supervisor(Exnake.Game, []),
      supervisor(Exnake.Food, []),
      supervisor(Exnake.Benchmark, []),
      worker(Exnake.Game.Loop, []),
      worker(Exnake.Game.FrameBroadcaster, []),
      # Exnake.Repo,
      ExnakeWeb.Telemetry,
      {Phoenix.PubSub, name: Exnake.PubSub},
      ExnakeWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Exnake.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ExnakeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
