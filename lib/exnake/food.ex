defmodule Exnake.Food do
  @defmodule """
  This GenServer handles food creation and collision.
  """

  use GenServer
  require Logger
  alias Exnake.Player
  alias Exnake.Food.Controller

  ## Client

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def next_state(game_state) do
    food_state = GenServer.call(__MODULE__, {:next_state, game_state})
    Map.merge(game_state, %{food: food_state})
  end

  ## Server Callbacks

  def init(:ok, food_map) do
    {:ok, food_map}
  end

  def handle_call({:next_state, player_states}, _from, food_map) do
    new_food_map = Controller.calculate_next_frame(food_map, player_states)
    {:reply, new_food_map, new_food_map}
  end
end
