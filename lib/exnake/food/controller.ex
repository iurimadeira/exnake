defmodule Exnake.Food.Controller do
  alias Exnake.Player
  alias Exnake.Game.Settings
  alias Exnake.Player.State

  def calculate_next_frame(food_map, %{players: players} = game_state) do
    {food_map, game_state}
    |> check_food_collision
    |> add_new_random_foods(players)
  end

  def check_food_collision({food_map, game_state}) do
    Enum.map(food_map, fn (food) ->
      case find_player_by_head(game_state, food) do
        nil -> food
        %Player.State{id: id} ->
          Player.eat_food(id)
          nil
      end
    end) |> Enum.reject(&is_nil/1)
  end

  defp find_player_by_head(%{players: players}, position) do
    result = Enum.filter(players, fn (player) ->
      player.head_position == position
    end)
    case result do
      [player] -> player
      [] -> nil
      _ -> :error
    end
  end

  def add_new_random_foods(food_map, players)
    when length(food_map) >= length(players),
    do: food_map
  def add_new_random_foods(food_map, players) do
    IO.inspect(length(players))
    add_new_random_foods(food_map ++ [generate_random_food()], players)
  end

  #TODO Make sure this position is empty
  def generate_random_food do
    x = :rand.uniform(Settings.map_width()) - 1
    y = :rand.uniform(Settings.map_height()) - 1
    %{x: x, y: y}
  end
end
