defmodule Exnake.Player.State do
  @defmodule """
  This module holds the state of a player's snake.
  The position element holds an array of %Square{}
  The direction element holds an atom with the direction name (:up, :down...)
  """
  defstruct :position, :direction
end
