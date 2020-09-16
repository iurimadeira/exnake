defmodule Exnake.Game.FrameBroadcaster do
  use GenServer
  alias Exnake.{Endpoint, Game}

  @game_states_per_second 10
  @tick_duration trunc(1000 / @game_states_per_second)

  ## Client

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  ## Server
  def init([]) do
    schedule_frame_broadcast()

    {:ok, %{last_tick: NaiveDateTime.utc_now()}}
  end

  def handle_info({:broadcast_frame}, %{last_tick: last_tick}) do
    now = NaiveDateTime.utc_now()
    next_game_state_at = NaiveDateTime.add(last_tick, @tick_duration, :millisecond)

    new_last_tick =
      if NaiveDateTime.compare(next_game_state_at, now) == :lt do
        Endpoint.broadcast("game:play", "new_frame", %{frame: Game.calculate_next_frame()})
        GenServer.cast(Exnake.Benchmark, {:register_new_game_state})
        now
      else
        GenServer.cast(Exnake.Benchmark, {:register_skip})
        last_tick
      end

    schedule_frame_broadcast()

    {:noreply, %{last_tick: new_last_tick}}
  end

  def schedule_frame_broadcast(), do: send(self(), {:broadcast_frame})
end
