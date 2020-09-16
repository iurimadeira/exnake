defmodule Exnake.Game.FrameBroadcaster do
  use GenServer
  alias ExnakeWeb.Endpoint
  alias Exnake.Game

  @ticks_per_second 5
  @tick_duration trunc(1000 / @ticks_per_second)

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
        last_frame = GenServer.call(Exnake.Game.Loop, {:get_last_game_state})
        Endpoint.broadcast("game:play", "new_frame", %{frame: last_frame})
        GenServer.cast(Exnake.Benchmark, {:register_new_tick})
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
