defmodule Exnake.Game do
  use Supervisor

  ## Client

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def join(user_id) do
    Supervisor.start_child(__MODULE__, [user_id])
    {:ok, %{id: user_id}}
  end

  def leave(user_id) do
    pid = :global.whereis_name(user_id)
    Supervisor.terminate_child(__MODULE__, pid)
  end

  ## Server

  def init(:ok) do
    children = [
      worker(Exnake.Player, [], [restart: :transient])
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
