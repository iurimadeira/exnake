defmodule Exnake.Player do
  @defmodule """
  This GenServer holds a single player state.
  It also calculates its position in the next frame, as well as its collision
  and score.
  """

  use GenServer
  require Logger
  alias Exnake.Player.Movement

  defmodule State do
    defstruct id: nil,
      body_position: [],
      direction: :up
  end

  ## Client

  def start_link(user_id) do
    state = %State{id: user_id, body_position: new_player_body()}
    GenServer.start_link(__MODULE__, state, [name: {:global, user_id}] )
  end

  defp new_player_body do
    [%{x: 10, y: 10}, %{x: 10, y: 11}, %{x: 10, y: 12}, %{x: 10, y: 13}]
  end

  def change_direction(user_id, "up"), do: change_direction(user_id, :up)
  def change_direction(user_id, "down"), do: change_direction(user_id, :down)
  def change_direction(user_id, "left"), do: change_direction(user_id, :left)
  def change_direction(user_id, "right"), do: change_direction(user_id, :right)
  def change_direction(user_id, direction) when is_atom(direction) do
    pid = :global.whereis_name(user_id)
    GenServer.cast(pid, {:change_direction, direction})
  end

  def next_state(pid), do: GenServer.call(pid, {:next_state})

  ## Server Callbacks

  def init(:ok, state) do
    {:ok, state}
  end

  def handle_cast({:change_direction, direction}, state = %State{}) do
    {:noreply, Movement.change_direction(state, direction)}
  end

  def handle_call({:next_state}, _from, state = %State{}) do
    new_state = calculate_next_state(state)
    {:reply, new_state, new_state}
  end

  defp calculate_next_state(%{body_position: body_position} = state) do
    [head | _] = body_position
    new_body = [calculate_next_head_position(head, state.direction) | body_position]
      |> Enum.drop(-1)

    %{state | body_position: new_body}
  end

  defp calculate_next_head_position(%{x: x, y: y}, :up), do: %{x: x, y: y - 1}
  defp calculate_next_head_position(%{x: x, y: y}, :down), do: %{x: x, y: y + 1}
  defp calculate_next_head_position(%{x: x, y: y}, :left), do: %{x: x - 1, y: y}
  defp calculate_next_head_position(%{x: x, y: y}, :right), do: %{x: x + 1, y: y}

end
