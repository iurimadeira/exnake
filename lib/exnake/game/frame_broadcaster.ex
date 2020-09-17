defmodule Exnake.Game.FrameBroadcaster do
  use GenServer
  alias ExnakeWeb.Endpoint
  alias Exnake.Game

  @ticks_per_second 10
  @tick_duration trunc(1000 / @ticks_per_second)

  ## Client

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  ## Server
  def init([]) do
    schedule_frame_broadcast()

    {:ok, %{last_tick: NaiveDateTime.utc_now(), last_frame: ""}}
  end

  def handle_info({:broadcast_frame}, %{last_tick: last_tick, last_frame: last_frame}) do
    now = NaiveDateTime.utc_now()
    next_game_state_at = NaiveDateTime.add(last_tick, @tick_duration, :millisecond)

    {new_last_tick, new_last_frame} =
      if NaiveDateTime.compare(next_game_state_at, now) == :lt do
        {count, new_frame} = get_new_frame()
        delta = get_delta(last_frame, new_frame)

        Endpoint.broadcast("game:play", "new_frame", %{count: count, delta: delta})

        GenServer.cast(Exnake.Benchmark, {:register_new_tick})
        {now, new_frame}
      else
        GenServer.cast(Exnake.Benchmark, {:register_skip})
        {last_tick, last_frame}
      end

    schedule_frame_broadcast()

    {:noreply, %{last_tick: new_last_tick, last_frame: new_last_frame}}
  end

  def get_new_frame() do
    %{game_state_count: count, last_game_state: last_game_state} =
      GenServer.call(Exnake.Game.Loop, {:get_last_game_state})

    last_game_state = Jason.encode!(last_game_state)
    {count, last_game_state}
  end

  def get_delta(last_frame, new_frame) do
    Exnake.Differ.encode(last_frame, new_frame)
  end

  def schedule_frame_broadcast(), do: send(self(), {:broadcast_frame})
end
