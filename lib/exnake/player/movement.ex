defmodule Exnake.Player.Movement do
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

  def calculate_next_state(%{body_position: body_position} = state) do
    [head | _] = body_position
    new_body = [calculate_next_head_position(head, state.direction) | body_position]
      |> Enum.drop(-1)

    %{state | body_position: new_body}
  end

  defp calculate_next_head_position(%{x: x, y: y}, :up), do: %{x: x, y: y - 1}
  defp calculate_next_head_position(%{x: x, y: y}, :down), do: %{x: x, y: y + 1}
  defp calculate_next_head_position(%{x: x, y: y}, :left), do: %{x: x - 1, y: y}
  defp calculate_next_head_position(%{x: x, y: y}, :right), do: %{x: x + 1, y: y}
end
