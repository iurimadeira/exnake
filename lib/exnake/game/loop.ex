defmodule Exnake.Game.Loop do
  use GenServer
  alias ExnakeWeb.Endpoint
  alias Exnake.Game

  require Logger

  @loop_interval 200

  ## Client

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  ## Server
  def init([]) do
    schedule_new_loop()

    {:ok, %{last_loop: NaiveDateTime.utc_now(), game_state_count: 0, last_game_state: %{}}}
  end

  def handle_call({:get_last_game_state}, _from, state) do
    {:reply, state, state}
  end

  def handle_info({:calculate_game_state}, %{
        last_loop: last_loop,
        game_state_count: game_state_count,
        last_game_state: last_game_state
      }) do
    now = NaiveDateTime.utc_now()
    next_game_state_at = NaiveDateTime.add(last_loop, @loop_interval, :millisecond)

    {new_game_state_count, new_last_loop, new_last_game_state} =
      if NaiveDateTime.compare(next_game_state_at, now) == :lt do
        new_game_state = Game.calculate_next_frame()

        Logger.debug(
          "[#{now}] New game state calculated (#{game_state_count + 1})! \n #{
            inspect(new_game_state)
          }"
        )

        {game_state_count + 1, now, new_game_state}
      else
        {game_state_count, last_loop, last_game_state}
      end

    schedule_new_loop()

    {:noreply,
     %{
       last_loop: new_last_loop,
       game_state_count: new_game_state_count,
       last_game_state: new_last_game_state
     }}
  end

  def schedule_new_loop(), do: send(self(), {:calculate_game_state})
end
