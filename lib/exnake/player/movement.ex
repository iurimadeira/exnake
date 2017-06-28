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

end
