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

  ## Server Callbacks

  def init(:ok, state) do
    {:ok, state}
  end

  def handle_cast({:change_direction, direction}, state = %State{}) do
    {:noreply, Movement.change_direction(state, direction)}
  end

  def handle_cast({:eat_food}, state = %State{}) do
    {:noreply, Action.eat_food(state)}

  def handle_call({:next_state}, _from, state = %State{}) do
    new_state = Movement.calculate_next_state(state)
    {:reply, new_state, new_state}
  end
end
