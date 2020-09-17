defmodule ExnakeWeb.GameChannel do
  use ExnakeWeb, :channel
  alias ExnakeWeb.Endpoint
  alias Exnake.{Game, Player}
  require Logger

  def join("game:play", %{"name" => name} = payload, socket) do
    if authorized?(payload) do
      Logger.debug("#{socket.assigns.user_id} joined the Play channel")

      case Game.join(socket.assigns.user_id, name) do
        {:ok, response} ->
          send(self, {:after_join, payload})
          {:ok, response, socket}

        error ->
          error
      end
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info({:after_join, _payload}, socket) do
    %{game_state_count: count, last_game_state: last_game_state} =
      GenServer.call(Exnake.Game.Loop, {:get_last_game_state})

    push(socket, "starting_state", %{count: count, frame: last_game_state})

    {:noreply, socket}
  end

  def terminate(_reason, socket) do
    Logger.debug("#{socket.assigns.user_id} left the Play channel")
    Game.leave(socket.assigns.user_id)
    socket
  end

  def handle_in("change_direction", %{"direction" => direction} = payload, socket) do
    Player.change_direction(socket.assigns.user_id, direction)
    {:reply, {:ok, payload}, socket}
  end

  defp authorized?(_payload), do: true
end
