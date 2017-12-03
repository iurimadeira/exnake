defmodule Exnake.Player.Spawn do
  require Logger
  use Exnake.Game.Settings
  alias Exnake.Player.State

  @initial_size 4

  def new_player_state(user_id, name) do
    %State{id: user_id, name: name}
    |> add_random_head_position
    |> add_random_direction
    |> add_player_body
  end

  @doc """
  A new player always spawns with the head pointing up. So no :down direction.
  """
  defp add_random_direction(state) do
    direction = Enum.random([:up, :left, :right])
    %{state | direction: direction} 
  end

  defp add_random_head_position(state) do
    x = :rand.uniform(@map_width) - 1
    y = :rand.uniform(@map_height) - 1
    %{state | head_position: %{x: x, y: y}}
  end

  defp add_player_body(%{head_position: head} = state) do
    Logger.debug "New player spawned at %{x: #{head.x}, y: #{head.y}"
    body = Enum.map((0..@initial_size - 1), fn (square) ->
      %{x: head.x, y: head.y + square}
    end)
    %{state | body_position: body}
  end
  
end
