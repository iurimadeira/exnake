defmodule Exnake.Game do
  use Supervisor
  require Logger
  alias Exnake.{Endpoint, Player, Game, Food}

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

  def die(_user_id), do: nil

  def next_frame do
    start_time = :os.system_time(:microsecond)
    next_frame = calculate_next_frame()
    end_time = :os.system_time(:microsecond)
    Logger.debug "Calculated new frame for #{length(all_players_pids())} players in #{(end_time - start_time)}μs"
    next_frame
  end

  defp calculate_next_frame do
    %{players: next_player_states()}
    |> Player.check_body_collisions
    |> Food.next_state
    |> format_frame
  end

  defp format_frame(%{players: players_state} = state) do
    players = Enum.map(players_state, fn (state) ->
      %{body_position: body_position, score: score, id: id} = state
      %{body: body_position, score: score, id: id}
    end)
    %{state | players: players}
  end

  defp next_player_states do
    Enum.map(all_players_pids(), fn (pid) ->
      Player.next_state(pid)
    end)
  end

  def all_players_pids do
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
