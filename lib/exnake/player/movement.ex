defmodule Exnake.Player.Movement do
  @defmodule """
  This module holds the functions related to player movement.
  Mainly called by Exnake.Player
  """

  require Logger

  def change_direction(%{direction: :left} = state, :left), do: state
  def change_direction(%{direction: :left} = state, :right), do: state
  def change_direction(%{direction: :right} = state, :left), do: state
  def change_direction(%{direction: :right} = state, :right), do: state
  def change_direction(%{direction: :up} = state, :up), do: state
  def change_direction(%{direction: :up} = state, :down), do: state
  def change_direction(%{direction: :down} = state, :up), do: state
  def change_direction(%{direction: :down} = state, :down), do: state
  def change_direction(state, direction) do
    Logger.debug "#{state.id} changed direction from #{state.direction} do direction"
    %{state | direction: direction}
  end

  def calculate_next_state(%{body_position: [head | _]} = state) do
    new_body = {head, state.direction}
      |> calculate_next_head_position
      |> check_edges
      |> merge_rest_of_body(state.body_position)

    %{state | body_position: new_body}
  end

  defp calculate_next_head_position({%{x: x, y: y}, :up}), do: %{x: x, y: y - 1}
  defp calculate_next_head_position({%{x: x, y: y}, :down}), do: %{x: x, y: y + 1}
  defp calculate_next_head_position({%{x: x, y: y}, :left}), do: %{x: x - 1, y: y}
  defp calculate_next_head_position({%{x: x, y: y}, :right}), do: %{x: x + 1, y: y}

  defp check_edges(%{x: -1, y: y}), do: %{x: 100, y: y}
  defp check_edges(%{x: 101, y: y}), do: %{x: 0, y: y}
  defp check_edges(%{x: x, y: -1}), do: %{x: x, y: 72}
  defp check_edges(%{x: x, y: 73}), do: %{x: x, y: 0}
  defp check_edges(head), do: head

  defp merge_rest_of_body(head, old_body) do
    new_body = Enum.drop(old_body, -1)
    [head | new_body]
  end
end
