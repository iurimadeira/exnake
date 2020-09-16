defmodule Exnake.Game.Loop do
  use GenServer
  alias ExnakeWeb.Endpoint
  alias Exnake.Game

  require Logger

  @loop_interval 1000

  ## Client

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  ## Server
  def init([]) do
    schedule_new_loop()

    {:ok, %{last_loop: NaiveDateTime.utc_now(), last_game_state: %{}}}
  end

  def handle_call({:get_last_game_state}, _from, %{last_game_state: last_game_state} = state) do
    {:reply, last_game_state, state}
  end

  def handle_info({:calculate_game_state}, %{
        last_loop: last_loop,
        last_game_state: last_game_state
      }) do
    now = NaiveDateTime.utc_now()
    next_game_state_at = NaiveDateTime.add(last_loop, @loop_interval, :millisecond)

    {new_last_loop, new_last_game_state} =
      if NaiveDateTime.compare(next_game_state_at, now) == :lt do
        new_game_state = Game.calculate_next_frame()
        Logger.debug("[#{now}] New game state calculated! \n #{inspect(new_game_state)}")

        {now, new_game_state}
      else
        {last_loop, last_game_state}
      end

    schedule_new_loop()

    {:noreply, %{last_loop: new_last_loop, last_game_state: new_last_game_state}}
  end

  def schedule_new_loop(), do: send(self(), {:calculate_game_state})
end
