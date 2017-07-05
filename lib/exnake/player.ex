defmodule Exnake.Player do
  @defmodule """
  This GenServer holds a single player state.
  It also calculates its position in the next frame, as well as its collision
  and score.
  """

  use GenServer
  require Logger
  alias Exnake.Player.{Spawn, State, Movement, Action}

  ## Client

  def start_link(user_id) do
    state = Spawn.new_player_state(user_id)
    GenServer.start_link(__MODULE__, state, [name: {:global, user_id}] )
  end

  def die(user_id),
    do: GenServer.cast(player_pid(user_id), {:die})

  def eat_food(user_id),
    do: GenServer.cast(player_pid(user_id), {:eat_food})

  def change_direction(user_id, "up"), do: change_direction(user_id, :up)
  def change_direction(user_id, "down"), do: change_direction(user_id, :down)
  def change_direction(user_id, "left"), do: change_direction(user_id, :left)
  def change_direction(user_id, "right"), do: change_direction(user_id, :right)
  def change_direction(user_id, direction) when is_atom(direction),
    do: GenServer.cast(player_pid(user_id), {:change_direction, direction})

  def next_state(pid), do: GenServer.call(pid, {:next_state})

  def player_pid(user_id), do: :global.whereis_name(user_id)

  def check_body_collisions(%{players: player_states}) do
    result = player_states
      |> get_collisions
      |> kill_collided_players

    %{players: result}
  end

  defp kill_collided_players({player_states, collisions}) do
    players = Enum.map(player_states, fn (state) ->
      if Enum.member?(collisions, state.head_position) do
        __MODULE__.die(state.id)
        nil
      else
        state
      end
    end) |> Enum.reject(&is_nil/1)
  end

  @doc "Get collisions by looking for duplicated body_positions"
  defp get_collisions(player_states) do
    positions = Enum.map(player_states, fn (state) ->
      %{body_position: body_position} = state
      body_position
    end) |> List.flatten

    collisions = positions -- Enum.uniq(positions)
    {player_states, collisions}
  end

  # Server Callbacks

  def init(:ok, state) do
    {:ok, state}
  end

  def handle_cast({:die}, state) do
    {:noreply, Action.die(state)}
  end

  def handle_cast({:change_direction, direction}, %{dead: true} = state),
    do: {:noreply, state}
  def handle_cast({:change_direction, direction}, state = %State{}) do
    {:noreply, Movement.change_direction(state, direction)}
  end

  def handle_cast({:eat_food}, %{dead: true} = state),
    do: {:noreply, state}
  def handle_cast({:eat_food}, state = %State{}) do
    {:noreply, Action.eat_food(state)}
  end

  def handle_call({:next_state}, _from, %{dead: true} = state),
    do: {:reply, state, state}
  def handle_call({:next_state}, _from, state = %State{}) do
    new_state = Movement.calculate_next_state(state)
    {:reply, new_state, new_state}
  end
end
