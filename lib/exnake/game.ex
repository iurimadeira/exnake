defmodule Exnake.Game do
  use Supervisor
  require Logger
  alias Exnake.{Endpoint, Player, Game}

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

  def next_frame do
    # Get next_state from all players
    next_states = Enum.map(all_players_pids, fn (pid) ->
      %{body_position: body_position} = Player.next_state(pid)
      body_position
    end)
  end

  defp all_players_pids do
    Enum.map(Supervisor.which_children(__MODULE__), fn (children) ->
      {_, pid, _, _} = children
      pid
    end)
  end

  ## Server Callbacks

  def init(:ok) do
    children = [
      worker(Exnake.Player, [], [restart: :transient])
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
