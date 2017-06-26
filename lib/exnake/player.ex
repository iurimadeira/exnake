defmodule Exnake.Player do
  @defmodule """
  This GenServer holds a single player state.
  It also calculates its position in the next frame, as well as its collision
  and score.
  """

  use GenServer
  require Logger

  defmodule State do
    defstruct id: nil,
      body_position: [],
      direction: :up
  end

  ## Client

  def start_link(user_id) do
    state = %State{id: user_id}
    GenServer.start_link(__MODULE__, state, [name: {:global, user_id}] )
  end

  def change_direction(user_id, direction) do
    pid = :global.whereis_name(user_id)
    GenServer.cast(pid, {:change_direction, direction})
  end

  def next_state(pid), do: GenServer.call(pid, {:next_state})

  ## Server

  def init(:ok, state) do
    {:ok, state}
  end

  def handle_cast({:change_direction, direction}, state = %State{}) do
    Logger.debug "Player #{state.id} changed direction from #{state.direction} to #{direction}"
    {:noreply, %{state | direction: direction}}
  end

  def handle_call({:next_state}, state = %State{}),
    do: {:reply, :ok, calculate_next_state(state)}

  defp calculate_next_state(%{body_position: [head | body]} = state) do
    new_body = [calculate_next_head_position(head, direction) | body]
    |> Enum.drop(-1)

    %{state | body_position: new_body}
  end

  defp calculate_next_head_position(%{x: x, y: y}, :up), do: %{x: x, y: y + 1}
  defp calculate_next_head_position(%{x: x, y: y}, :down), do: %{x: x, y: y - 1}
  defp calculate_next_head_position(%{x: x, y: y}, :left), do: %{x: x, y: y + 1}
  defp calculate_next_head_position(%{x: x, y: y}, :right), do: %{x: x, y: y - 1}

end
