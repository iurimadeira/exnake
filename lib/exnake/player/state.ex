defmodule Exnake.Player.State do
  defstruct id: nil,
    name: "",
    dead: false,
    score: 0,
    body_position: [],
    head_position: nil,
    direction: :up,
    food_eaten: false
end
