defmodule Exnake.Game.Settings do
  defmacro __using__(_) do
    quote do
      @square_size 10
      @map_width 160
      @map_height 90
      @food_score_value 10
      @food_factor 10
    end
  end
end
