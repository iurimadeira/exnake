defmodule Exnake.Game.FrameBroadcaster do
  use GenServer
  alias Exnake.{Endpoint, Game}

  ## Client

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  ## Server

  def init([]) do
    schedule_broadcast_frame()
    {:ok, []}
  end

  def handle_info(:broadcast_frame, []) do
    Endpoint.broadcast("game:play", "new_frame", %{frame: Game.next_frame()})
    schedule_broadcast_frame()
    {:noreply, []}
  end

  defp schedule_broadcast_frame do
    Process.send_after(self(), :broadcast_frame, 300)
  end
end
