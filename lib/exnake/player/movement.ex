defmodule Exnake.Player.Movement do
  @moduledoc """
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
    %{state | move_lock: true, direction: direction}
  end

  def calculate_next_state(state) do
    state
    |> add_next_head_position
    |> check_edges
    |> add_rest_of_body
  end

  defp add_next_head_position(%{direction: :up, head_position: %{x: x, y: y}} = state),
    do: %{state | head_position: %{x: x, y: y - 1}}
  defp add_next_head_position(%{direction: :down, head_position: %{x: x, y: y}} = state),
    do: %{state | head_position: %{x: x, y: y + 1}}
  defp add_next_head_position(%{direction: :left, head_position: %{x: x, y: y}} = state),
    do: %{state | head_position: %{x: x - 1, y: y}}
  defp add_next_head_position(%{direction: :right, head_position: %{x: x, y: y}} = state),
    do: %{state | head_position: %{x: x + 1, y: y}}

  defp check_edges(%{head_position: %{x: -1, y: y}} = state),
    do: %{state | head_position: %{x: 99, y: y}}
  defp check_edges(%{head_position: %{x: 100, y: y}} = state),
    do: %{state | head_position: %{x: 0, y: y}}
  defp check_edges(%{head_position: %{x: x, y: -1}} = state),
    do: %{state | head_position: %{x: x, y: 71}}
  defp check_edges(%{head_position: %{x: x, y: 72}} = state),
    do: %{state | head_position: %{x: x, y: 0}}
  defp check_edges(head), do: head

  defp add_rest_of_body(%{body_position: old_body, food_eaten: true} = state) do
    %{state | body_position: [state.head_position | old_body], food_eaten: false}
  end
  defp add_rest_of_body(%{body_position: old_body} = state) do
    new_body = Enum.drop(old_body, -1)
    %{state | body_position: [state.head_position | new_body]}
  end
end
