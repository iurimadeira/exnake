defmodule Exnake.Player.Action do
  @moduledoc """
  This module holds the functions that represents player actions, and are not
  related to movement, like eat_food and die.
  Mainly called by Exnake.Player
  """

  require Logger
  import Exnake.Game.Settings

  def eat_food(%{score: score} = state) do
    state
    |> add_food_score
    |> add_body_square
  end

  defp add_food_score(%{score: score} = state),
    do: %{state | score: score + food_score_value()}

  defp add_body_square(state),
    do: %{state | food_eaten: true}
end
