defmodule Exnake.Food.Controller do
  use Exnake.Game.Settings
  alias Exnake.Player
  alias Exnake.Player.State

  def calculate_next_frame(food_map, %{players: players} = game_state) do
    {food_map, game_state}
    |> check_food_collision
    |> add_new_random_foods(players)
  end

  def check_food_collision({food_map, game_state}) do
    Enum.map(food_map, fn food ->
      case find_player_by_head(game_state, food) do
        nil ->
          food

        %Player.State{id: id} ->
          Player.eat_food(id)
          nil
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp find_player_by_head(%{players: players}, position) do
    result =
      Enum.filter(players, fn player ->
        player.head_position == position
      end)

    case result do
      [player] -> player
      [] -> nil
      _ -> :error
    end
  end

  def add_new_random_foods(food_map, players) do
    if length(food_map) < maximum_food_quantity(players) do
      add_new_random_foods(food_map ++ [generate_random_food()], players)
    else
      food_map
    end
  end

  def maximum_food_quantity(players) do
    length(players) * @food_factor
  end

  # TODO Make sure this position is empty
  def generate_random_food do
    x = :rand.uniform(@map_width) - 1
    y = :rand.uniform(@map_height) - 1
    %{x: x, y: y}
  end
end
