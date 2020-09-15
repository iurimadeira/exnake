defmodule Exnake.Game.FrameBroadcaster do
  use GenServer
  alias Exnake.{Endpoint, Game}

  @game_states_per_second 10
  @tick_duration 1000 / @game_states_per_second

  ## Client

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  ## Server
  def init([]) do
    calculate_game_state(NaiveDateTime.utc_now(), trunc(@tick_duration))

    {:ok, []}
  end

  def calculate_game_state(last_tick, tick_duration) do
    now = NaiveDateTime.utc_now()
    next_game_state_at = NaiveDateTime.add(last_tick, tick_duration, :millisecond)

    new_last_tick =
      if NaiveDateTime.compare(next_game_state_at, now) == :lt do
        Endpoint.broadcast("game:play", "new_frame", %{frame: Game.calculate_next_frame()})
        GenServer.cast(Exnake.Benchmark, {:register_new_game_state})
        now
      else
        GenServer.cast(Exnake.Benchmark, {:register_skip})
        last_tick
      end

    calculate_game_state(new_last_tick, tick_duration)
  end
end
