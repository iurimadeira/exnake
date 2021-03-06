defmodule Exnake do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # supervisor(Exnake.Repo, []),
      supervisor(Exnake.Endpoint, []),
      supervisor(Exnake.Game, []),
      supervisor(Exnake.Food, []),
      supervisor(Exnake.Benchmark, []),
      worker(Exnake.Game.FrameBroadcaster, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Exnake.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Exnake.Endpoint.config_change(changed, removed)
    :ok
  end
end
