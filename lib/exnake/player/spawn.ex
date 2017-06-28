defmodule Exnake.Player.Spawn do
  require Logger
  alias Exnake.Player.State
  alias Exnake.Game.Settings

  @initial_size 4

  def new_player_state(user_id) do
    %State{
      id: user_id,
      direction: random_direction(),
      body_position: new_player_body()
    }
  end

  @doc """
  A new player always spawns with the head pointing up. So no :down direction.
  """
  defp random_direction,
    do: Enum.random([:up, :left, :right])

  defp random_head_position do
    x = :rand.uniform(Settings.map_width()) - 1
    y = :rand.uniform(Settings.map_height()) - 1
    IO.inspect %{x: x, y: y}
  end

  defp new_player_body do
    %{x: x, y: y} = random_head_position()
    IO.inspect "got here"
    Logger.debug "New player spawned at %{x: #{x}, y: #{y}"
    Enum.map((0..@initial_size - 1), fn (square) ->
      %{x: x, y: y + square}
    end)
  end
  
end
