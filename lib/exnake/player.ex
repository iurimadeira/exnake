defmodule Exnake.Player do
  @defmodule """
  This GenServer holds a single player state.
  It also calculates its position in the next frame, as well as its collision
  and score.
  """

  use GenServer
  alias Exnake.Player.State

  ## Client

  def start_link do
    GenServer.start_link(__MODULE__, :ok, %State{})
  end

  ## Server

  def init(:ok, player_state) do
    {:ok, player_state}
  end

  def handle_cast({:change_direction, direction}, player_state = %State{}),
    do: {:noreply, %{player_state | direction: direction}}

  def handle_call({:next_state}, player_state = %State{}) do
    #TODO Calculate next position of all squares
  end

end
